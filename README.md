# Clixx GitOps Platform

A production-style AWS and Kubernetes platform demonstrating lifecycle-isolated Terraform, governed Jenkins orchestration, pull-based GitOps, persistent-data protection, and tested disaster recovery.

[View the documentation site](https://xtinead.github.io/clixx-gitops-platform/)

## Project Summary

The Clixx GitOps Platform demonstrates how a platform can be designed to be recoverable—not merely deployable.

The system combines:

- Amazon EKS for Kubernetes orchestration;
- Terraform for AWS infrastructure and lifecycle isolation;
- Jenkins for validation, saved plans, approvals, teardown, and controlled recovery;
- Argo CD for pull-based application reconciliation;
- Amazon RDS and Amazon EFS for persistent application data;
- AWS Backup for protected EFS recovery points;
- Amazon ECR for immutable rebuild-critical images;
- External Secrets and AWS Secrets Manager for runtime credentials;
- ExternalDNS and Route 53 for cross-account DNS;
- Prometheus, Grafana, Metrics Server, and HPA for observability and scaling.

The deployable implementation is maintained separately. This public repository contains sanitized architecture documentation, representative Terraform examples, decision records, runbooks, case studies, and operational evidence.

## What This Project Demonstrates

- Infrastructure organized by ownership and lifecycle rather than one monolithic state.
- Shared foundations that survive environment teardown.
- Reviewed Terraform plans and approval gates.
- Pull-based delivery with Argo CD as the routine application authority.
- Controlled Jenkins access for exceptional lifecycle and recovery operations.
- Cross-account DNS with a narrow IAM trust path.
- Independent RDS and EFS recovery procedures.
- Repeatable platform teardown and reconstruction.
- Evidence-based validation of application, data, DNS, monitoring, and autoscaling recovery.

## Architecture Principles

- **Git is the source of truth for runtime applications.**
- **Terraform owns AWS infrastructure and the GitOps control plane.**
- **Jenkins orchestrates plans, approvals, lifecycle operations, and recovery.**
- **Argo CD owns routine Kubernetes application reconciliation.**
- **Remote state, images, DNS authorization, and backup controls survive cluster replacement.**
- **Persistent data is protected independently from replaceable compute.**
- **Human standing privilege remains limited.**
- **Destructive actions fail closed without explicit confirmation and valid recovery sources.**

## Lifecycle Architecture

| Domain | Owner | Lifecycle |
|---|---|---|
| Remote-state foundation | External prerequisite | Permanent |
| Workload execution identity | Terraform `bootstrap` root | Foundational administrative bootstrap |
| DNS execution identity | Terraform `dns-bootstrap` root | Foundational administrative bootstrap |
| Cross-account DNS | Terraform `dns-account` root | Shared; destruction blocked |
| Artifact registry | Terraform `artifact-registry` root | Shared; destruction blocked |
| Runtime infrastructure | Terraform `platform-infra` root | Environment-specific and replaceable |
| Data protection | Terraform `data-protection` root | Shared; destruction blocked |
| GitOps control plane | Terraform `platform-gitops` root | Environment-specific and replaceable |
| Runtime applications | Argo CD and Git | Continuously reconciled |
| Recovery operations | Jenkins and versioned scripts | On demand |

This separation allows the runtime environment to be removed and rebuilt without deleting the state, container image, DNS trust, or backup controls needed for recovery.

Read the [platform architecture](docs/platform-infra/architecture.md) and [Terraform lifecycle architecture](terraform/README.md).

## Delivery Responsibility Boundary

| System | Responsibility |
|---|---|
| Terraform | AWS infrastructure, shared platform foundations, and the Argo CD control plane |
| Jenkins | Validation, saved plans, approvals, orchestration, teardown, recovery, and verification |
| Argo CD | Routine Kubernetes application delivery and continuous reconciliation |
| Git | Desired runtime state, review history, and rollback source |
| Engineers | Review, approval, read-only inspection, and controlled administrative bootstrap |

Jenkins does not perform routine application deployment with `kubectl`. Its direct Kubernetes operations are restricted to documented bootstrap, teardown, recovery, and verification procedures that cannot safely be delegated to Argo CD.

## Terraform and State Design

All Terraform roots consume an externally established Amazon S3 backend with DynamoDB locking. The backend is a permanent prerequisite and is not owned by the replaceable EKS platform.

Separate backend keys isolate:

- execution-identity bootstrap;
- DNS authorization;
- artifact registry;
- platform infrastructure;
- data protection;
- GitOps control-plane state;
- environments.

The public repository omits backend names, account identifiers, role ARNs, and environment-specific secrets.

## Platform Infrastructure

The environment-specific infrastructure includes:

- multi-AZ VPC networking;
- public and private subnets;
- internet and NAT gateways;
- Amazon EKS and managed nodes;
- IAM roles, OIDC, and EKS access entries;
- Amazon RDS;
- Amazon EFS and mount targets;
- EFS CSI integration;
- AWS Load Balancer Controller;
- ExternalDNS workload identity;
- External Secrets workload identity;
- managed EKS add-ons.

## Shared Protected Foundations

### Artifact registry

Amazon ECR is isolated from the cluster lifecycle. The registry enforces immutable image handling, repository policy, scanning expectations, and retention controls. Destruction is blocked in the routine pipeline.

### Cross-account DNS

Route 53 is managed through a separate DNS-account trust path. The DNS Terraform root and ExternalDNS runtime role are scoped independently from the workload account.

### Data protection

The dedicated AWS Backup root manages:

- backup and restore service-role permissions;
- a protected backup vault;
- governance-mode vault lock;
- scheduled EFS backups;
- bounded retention;
- tag-based resource selection.

Tag-based selection allows the backup control plane to remain independent from replaceable EFS resources.

## Two-Phase Argo CD Bootstrap

The Argo CD root application cannot be planned on a new cluster until the Argo CD `Application` CRD exists.

The pipeline handles this dependency in two phases:

1. install the Argo CD namespace, Helm release, CRDs, ingress, and supporting resources;
2. wait for the CRD, generate another saved plan, request approval, and apply the repository credential and root application.

This makes first-cluster bootstrap deterministic while allowing later runs to converge normally.

## Controlled Teardown

The platform is removed in dependency order:

1. validate protected RDS and EFS recovery sources;
2. plan and approve GitOps destruction;
3. prune Argo CD-managed workloads while controllers still exist;
4. destroy the GitOps control plane;
5. disable RDS deletion protection through a separate reviewed plan;
6. require explicit infrastructure and database destruction confirmations;
7. destroy runtime infrastructure;
8. preserve state, ECR, DNS foundations, backup controls, and recovery points;
9. verify the approved recovery sources remain available.

## Tested Disaster Recovery

The platform completed a full teardown and recovery exercise on September 25, 2026.

The validated procedure included:

- selecting an encrypted protected RDS snapshot;
- restoring EFS through AWS Backup;
- adopting the restored filesystem into Terraform state;
- rebuilding VPC, EKS, RDS, EFS integrations, IAM, add-ons, and controllers;
- inspecting the restored EFS hierarchy;
- copying recovered application data into a dynamic PVC;
- bootstrapping Argo CD in two phases;
- restoring applications and secrets through Git reconciliation;
- repairing cross-account DNS trust;
- validating application data, HTTPS endpoints, metrics, and autoscaling.

### Validated outcomes

| Area | Outcome |
|---|---|
| Amazon EKS | Recreated with two healthy worker nodes |
| Amazon RDS | Restored from an encrypted protected snapshot |
| Amazon EFS | Restored through AWS Backup and adopted into Terraform state |
| Application data | 92 recovered files verified |
| Clixx | Two available replicas and successful rollout |
| Argo CD | Root and child applications synchronized and healthy |
| External Secrets | Database secret reconciled without storing credentials in Git |
| ExternalDNS | Cross-account trust restored and public records reconciled |
| Observability | Prometheus and Grafana restored |
| Autoscaling | HPA restored with validated replica boundaries |

Read the [disaster-recovery validation report](docs/disaster-recovery-validation.md) and [teardown/rebuild runbook](docs/platform-infra/teardown-rebuild.md).

## Security Model

- Jenkins uses temporary AWS STS sessions.
- Engineers retain read-only EKS access for routine inspection.
- Workloads use IAM roles associated through EKS OIDC.
- Application secrets are retrieved through External Secrets and AWS Secrets Manager.
- Cross-account DNS permissions are narrowly scoped.
- Saved plans and manual approvals protect material changes.
- RDS deletion protection requires a separate unlock workflow.
- Shared DNS, ECR, and data-protection destruction is blocked.
- Sensitive shell stages disable tracing and clean temporary files.
- Public documentation excludes account-specific and credential-bearing values.

Read the complete [security model](docs/platform-infra/security-model.md).

## Observability and Scaling

Operational visibility includes:

- Prometheus metrics collection;
- Grafana dashboards;
- cluster and node resource monitoring;
- namespace and workload views;
- Kubernetes Metrics Server;
- Horizontal Pod Autoscaling;
- post-recovery health and endpoint validation.

Evidence is available under [`docs/assets/screenshots`](docs/assets/screenshots/).

## Repository Guide

```text
.
├── diagrams/             # Public architecture diagrams
├── docs/
│   ├── adr/              # Architecture decision records
│   ├── assets/           # Operational screenshots and diagrams
│   ├── ci-cd/            # Jenkins and pipeline decisions
│   ├── platform-gitops/  # Argo CD and reconciliation model
│   └── platform-infra/   # Architecture, security, teardown, and recovery
├── gitops/               # Sanitized GitOps documentation
├── jenkins/              # Sanitized orchestration documentation
└── terraform/            # Sanitized Terraform examples and design documentation
```

## Start Here

- [Documentation home](docs/index.md)
- [Platform case study](docs/case-study.md)
- [Platform architecture](docs/platform-infra/architecture.md)
- [Terraform lifecycle architecture](terraform/README.md)
- [Jenkins orchestration](docs/ci-cd/jenkins-orchestration.md)
- [GitOps flow](docs/platform-gitops/gitops-flow.md)
- [Teardown and rebuild runbook](docs/platform-infra/teardown-rebuild.md)
- [Disaster-recovery validation](docs/disaster-recovery-validation.md)
- [Lessons learned](docs/lessons-learned.md)

## Architecture Decisions

The ADR set documents key decisions, including:

- GitOps for routine runtime delivery;
- isolated Terraform state and lifecycle boundaries;
- manual approval before Terraform apply;
- controlled Jenkins cluster access for lifecycle and recovery;
- separation of external remote state from execution-identity bootstrap.

See [`docs/adr`](docs/adr/).

## Why This Project Matters

This project demonstrates more than initial provisioning. It shows how a platform engineer reasons about:

- ownership and blast radius;
- state and dependency management;
- deployment governance;
- least privilege;
- data durability;
- failure handling;
- teardown safety;
- tested reconstruction;
- operational evidence and documentation.

It reflects a platform-ownership mindset: build systems that are secure, observable, recoverable, and maintainable by more than one engineer.

## Author

**Christine Adelusi**
Senior DevOps / Platform Engineer

AWS · Terraform · Kubernetes · Jenkins · Argo CD · GitOps · CI/CD · Prometheus · Grafana
