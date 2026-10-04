# Terraform Lifecycle Architecture

This directory documents the Terraform design used by the Clixx GitOps Platform.

The public repository contains sanitized examples and architecture documentation. The deployable implementation is maintained separately so account-specific configuration, operational state details, and protected infrastructure procedures are not exposed here.

## Design Goals

The Terraform architecture is organized around ownership and lifecycle rather than placing the entire platform in one state file.

The design aims to:

- reduce the blast radius of infrastructure changes;
- keep shared foundations independent from replaceable runtime resources;
- protect container images, DNS integration, backups, and remote state during teardown;
- isolate environments with separate backend keys and variable definitions;
- require reviewed plans and approval before changes are applied;
- support repeatable teardown, reconstruction, and disaster recovery;
- preserve the responsibility boundary between Terraform, Jenkins, and Argo CD.

## Remote-State Foundation

The platform consumes an externally established Amazon S3 backend with DynamoDB state locking.

These backend resources are long-lived prerequisites. They are not owned by the replaceable EKS platform and must survive teardown and recovery.

Each Terraform root uses an isolated backend key so unrelated lifecycle domains do not share one state file.

Example sanitized keys:

```text
bootstrap/<environment>.tfstate
dns-bootstrap/<environment>.tfstate
dns-account/<environment>.tfstate
artifact-registry/<environment>.tfstate
platform-infra/<environment>.tfstate
data-protection/<environment>.tfstate
platform-gitops/<environment>.tfstate
```

Backend names, account identifiers, role ARNs, and other environment-specific values are intentionally omitted from the public repository.

## Terraform Responsibility Domains

| Root | Responsibility | Lifecycle |
|---|---|---|
| `bootstrap` | Workload-account Terraform execution role and scoped IAM-management permissions | Foundational administrative bootstrap |
| `dns-bootstrap` | DNS-account Terraform execution role and narrow cross-account IAM-management permissions | Foundational administrative bootstrap |
| `dns-account` | Route 53 cross-account role and ExternalDNS policy | Shared and protected |
| `artifact-registry` | ECR repository, immutable image controls, scanning, repository policy, and retention | Shared and protected |
| `platform-infra` | VPC, subnets, NAT, EKS, nodes, RDS, EFS, IAM/OIDC, add-ons, controllers, and storage integration | Environment-specific and replaceable |
| `data-protection` | AWS Backup service role, vault, vault lock, plan, retention, and tag-based EFS selection | Shared and protected |
| `platform-gitops` | Argo CD, ingress, repository credential, and root application | Environment-specific and replaceable |

## Why the Roots Are Separate

### Execution identity is not runtime infrastructure

The workload and DNS bootstrap roots establish the identities required by later automation. They are controlled administrative procedures rather than ordinary Jenkins selections because the pipeline depends on the roles they create.

### Container images must survive cluster replacement

The artifact registry is independent from EKS. Destroying a cluster must not delete the immutable image required to rebuild and validate the application.

### DNS has a different account boundary

Cross-account Route 53 permissions use a dedicated execution path, trust relationship, and Terraform state. This limits the impact of DNS-policy changes and keeps hosted-zone access separate from workload-account infrastructure.

### Backup controls must survive protected resources

The data-protection root owns the backup control plane rather than the EFS filesystem itself. Tag-based selection protects matching EFS resources without coupling the backup plan to volatile platform outputs.

### GitOps depends on a live cluster

The platform-gitops root reads the platform-infra remote state to configure Kubernetes and Helm providers. EKS must exist before Argo CD can be installed or reconciled.

## State Dependencies

Direct state coupling is deliberately limited.

The principal remote-state relationship is:

```text
platform-infra state
        |
        v
platform-gitops providers and cluster context
```

Other shared domains use explicit configuration, account boundaries, tags, or AWS APIs instead of importing the entire platform state.

## Jenkins Orchestration

Jenkins manages the operational Terraform roots:

```text
platform-infra
platform-gitops
dns-account
artifact-registry
data-protection
```

The pipeline provides:

- parameter and environment validation;
- AWS STS role assumption;
- isolated backend initialization;
- Terraform formatting and validation;
- saved plans;
- manual approval before apply;
- layer-specific post-apply verification;
- explicit destruction confirmations;
- protected shared layers whose destruction is blocked;
- cleanup of temporary plans and recovery resources.

The `bootstrap` and `dns-bootstrap` roots remain outside routine pipeline selection because they establish the execution identities the pipeline subsequently uses.

## Initial Construction Sequence

1. Confirm the external state backend and lock table.
2. Establish the workload-account execution identity.
3. Establish the DNS-account execution identity.
4. Create and protect the artifact registry.
5. Configure cross-account DNS authorization.
6. Establish the data-protection control plane.
7. Provision platform infrastructure.
8. Bootstrap the GitOps control plane.
9. Allow Argo CD to reconcile runtime applications.
10. Validate application, DNS, ingress, monitoring, storage, and autoscaling behavior.

Because EFS protection is tag-based, the backup plan can exist before the first matching filesystem is created.

## Platform Infrastructure

The platform-infra root manages the replaceable runtime foundation:

- multi-AZ VPC networking;
- public and private subnets;
- internet and NAT gateways;
- Amazon EKS and managed node groups;
- EKS access entries;
- IAM roles and OIDC integration;
- Amazon RDS and database networking;
- Amazon EFS and mount targets;
- EFS CSI integration and storage class;
- AWS Load Balancer Controller;
- ExternalDNS workload identity;
- External Secrets workload identity;
- managed EKS add-ons.

RDS and EFS contain persistent application data, but their protection and recovery procedures are deliberately separated from ordinary runtime provisioning.

## Data Protection and Recovery

The data-protection root manages:

- a dedicated AWS Backup vault;
- governance-mode vault lock;
- daily EFS backups;
- bounded retention;
- backup and restore service-role permissions;
- tag-based protected-resource selection.

The tested recovery process restores EFS through AWS Backup, adopts the restored filesystem into Terraform state, restores RDS from an encrypted protected snapshot, rebuilds the runtime platform, and migrates recovered application files into the application PVC.

Recovery is orchestrated separately because copying application data is an operational procedure, not a declarative infrastructure change.

## Two-Phase Argo CD Bootstrap

The Argo CD root application cannot be planned on a new cluster until the Argo CD `Application` custom resource definition exists.

The pipeline therefore applies GitOps in two phases:

1. install the Argo CD namespace, Helm release, CRDs, ingress, and supporting resources;
2. wait for the `Application` CRD, create another saved plan, request approval, and apply the repository credential and root application.

Later runs converge normally once the CRD already exists.

## Controlled Teardown

The teardown order protects dependencies and recovery assets:

1. validate RDS snapshots and EFS recovery points;
2. prune Argo CD-managed workloads while Kubernetes controllers still exist;
3. destroy the platform-gitops root;
4. disable RDS deletion protection through a separately reviewed plan;
5. destroy platform-infra after explicit infrastructure and database confirmation;
6. preserve remote state, ECR images, DNS foundations, backup controls, and recovery points;
7. verify that approved recovery sources remain available.

## Responsibility Boundaries

| System | Primary responsibility |
|---|---|
| Terraform | AWS infrastructure, shared platform foundations, and the Argo CD control plane |
| Jenkins | Validation, saved plans, approvals, orchestration, teardown, recovery, and verification |
| Argo CD | Routine Kubernetes application delivery and continuous reconciliation from Git |
| Engineers | Review, approval, read-only inspection, incident analysis, and controlled administrative bootstrap |

Jenkins does not perform routine application deployment with `kubectl`. Direct Kubernetes operations are restricted to documented bootstrap, teardown, recovery, and verification procedures that cannot be safely delegated to Argo CD.

## Public Example Structure

The public `terraform/` directory contains sanitized materials such as:

```text
terraform/
├── environments/
├── modules/
│   ├── alb/
│   ├── eks/
│   ├── iam/
│   └── vpc/
├── README.md
└── terraform-refactor-case-study.md
```

These materials demonstrate design concepts. They are not a directly deployable copy of the private implementation.

## Related Documentation

- [Platform infrastructure architecture](../docs/platform-infra/architecture.md)
- [Jenkins orchestration](../docs/ci-cd/jenkins-orchestration.md)
- [Teardown and rebuild runbook](../docs/platform-infra/teardown-rebuild.md)
- [Disaster-recovery validation](../docs/disaster-recovery-validation.md)
- [Platform case study](../docs/case-study.md)
