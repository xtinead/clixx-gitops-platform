# Clixx GitOps Platform Engineering Portfolio

This repository documents the design, evolution, and operation of a production-style AWS + Kubernetes GitOps platform.

The platform demonstrates how to build a secure, reproducible infrastructure and delivery model using Terraform, Jenkins, and Argo CD.

Key areas of focus include:

- Platform safety and blast-radius control

- Terraform state isolation and remote state safety

- GitOps-driven delivery using Argo CD

- CI/CD orchestration with Jenkins

- Safe infrastructure rebuild and teardown strategies

## Platform Architecture

The platform architecture separates responsibilities across infrastructure provisioning, CI orchestration, and runtime reconciliation.

This ensures infrastructure governance while maintaining a secure GitOps delivery model.

## CI/CD Delivery Flow

The CI/CD pipeline orchestrates infrastructure changes and GitOps updates without granting Jenkins direct cluster access.

Key characteristics:

- Infrastructure changes gated by approval

- Jenkins updates GitOps manifests

- Argo CD reconciles cluster state

- Rollback handled via Git revert

## Platform Architecture Layers

The platform is composed of three intentional layers.

1. Bootstrap Layer (Permanent)

Provides foundational services that should never be destroyed.

Includes:

- Terraform backend (S3 + DynamoDB)

- State locking and protection

- Shared infrastructure prerequisites

This layer guarantees that platform rebuilds remain safe.

2. Platform Infrastructure Layer

Responsible for provisioning AWS primitives using Terraform.

Components include:

- VPC and networking

- Amazon EKS cluster

- IAM roles and policies

- RDS and EFS where required

- ALB ingress infrastructure

Infrastructure changes are governed through CI approval gates.

3. Platform GitOps Layer

Responsible for application delivery.

Managed through:

- Argo CD

- GitOps manifests

- Environment overlays

All runtime changes originate from Git.

There are no direct kubectl deployments from CI.

## Documentation Map

Detailed platform documentation is available below.

### Platform Design

- [Platform Infrastructure Architecture](docs\platform-infra\architecture.md)
- [GitOps Delivery Model](docs\platform-gitops\gitops-flow.md)
- [CI/CD Orchestration](docs\ci-cd\jenkins-orchestration.md)

### Engineering Decisions

- [Pipeline Design Decisions](docs\ci-cd\pipeline-design-decisions.md)
- [Security Model](docs\platform-infra\security-model.md)
- [Teardown & Rebuild Strategy](docs\platform-infra\teardown-rebuild.md)

### Platform Evolution

- [Platform Evolution](docs\platform-evolution.md)
- [Lessons Learned](C:\apps\portfolio\clixx-gitops-platform\docs\lessons-learned.md)
- [Platform Case Study](C:\apps\portfolio\clixx-gitops-platform\docs\case-study.md)

## Architecture Decisions

- [ADR-0001: Use GitOps for Runtime Delivery](adr/0001-use-gitops-for-runtime-delivery.md)
- [ADR-0002: Isolate Terraform State into a Bootstrap Layer](adr/0002-isolate-terraform-state-bootstrap.md)
- [ADR-0003: Prevent Jenkins from Deploying Directly to Kubernetes](adr/0003-prevent-jenkins-direct-cluster-access.md)
- [ADR-0004: Require Manual Approval Before Terraform Apply](adr/0004-require-manual-approval-before-terraform-apply.md)

## Real Engineering Challenges Solved

During the development of this platform, several real-world infrastructure and delivery challenges were encountered and addressed.

### Terraform State Safety

One of the early risks identified was accidental deletion of Terraform state infrastructure during platform teardown.

To mitigate this, the platform was redesigned to introduce a Bootstrap Layer responsible for:

- Terraform state storage (S3)

- State locking (DynamoDB)

This layer is permanent and prevents destructive operations from impacting Terraform state integrity.

## Infrastructure Rebuild Reliability

Infrastructure teardown and rebuild scenarios were tested to ensure platform resilience.

The architecture was refactored to ensure:

- Safe destruction of platform infrastructure

- Reprovisioning without manual intervention

- No dependency conflicts during rebuild

This allows the platform to be recreated from scratch using Terraform.

## Eliminating Direct Cluster Access from CI

A common anti-pattern in CI/CD pipelines is granting the CI system direct kubectl access to production clusters.

To improve security, this platform enforces a strict separation:

- Jenkins orchestrates infrastructure and Git updates

- Argo CD performs runtime reconciliation

Jenkins never interacts directly with the Kubernetes API.

This significantly reduces the blast radius of CI credentials.

## GitOps Drift Detection

Runtime drift was addressed using Argo CD reconciliation.

If cluster state diverges from the Git repository:

- Argo CD detects the drift

- The cluster is automatically reconciled

- Unauthorized changes are reverted

This ensures Git remains the single source of truth.

## Controlled Infrastructure Changes

Terraform changes are not automatically applied.

The CI/CD pipeline requires a manual approval gate before infrastructure changes are executed.

This prevents:

- Accidental infrastructure modification

- Unreviewed production changes

- Unsafe Terraform applies


# Platform Engineering Skills Demonstrated

This project demonstrates practical experience across several key areas of modern platform engineering.

## Infrastructure as Code

- Terraform modular architecture
- Environment-aware infrastructure design
- Remote state management (S3 + DynamoDB)
- Infrastructure lifecycle management
- Safe infrastructure teardown and rebuild

## Kubernetes & GitOps

- Amazon EKS cluster architecture
- Argo CD pull-based deployment model
- GitOps repository structure and overlays
- Drift detection and reconciliation
- Declarative Kubernetes configuration

## CI/CD Engineering

- Jenkins pipeline orchestration
- Infrastructure validation and planning
- Manual approval gates for governance
- GitOps repository updates from CI
- Pipeline observability via notifications

## Cloud Architecture

- AWS VPC and networking design
- Secure IAM role and policy management
- OIDC integration for Kubernetes workloads
- Load balancing and ingress architecture

## Platform Security

- CI isolation from cluster credentials
- Least privilege IAM design
- Git-based audit trail for deployments
- Approval gates for infrastructure changes

## Operational Reliability

- Platform rebuild testing
- Drift detection and reconciliation
- Version-controlled rollback strategy
- Infrastructure blast-radius control


## Why This Platform Exists

This repository demonstrates real-world DevOps and platform engineering practices, including:

- Infrastructure modularization

- GitOps-based deployment

- CI/CD governance controls

- Cloud-native architecture

- Secure runtime delivery patterns

The goal is to show how infrastructure, CI/CD, and GitOps can work together to produce a safe and repeatable platform engineering workflow.

## Author

Christine Adelusi

Senior DevOps / Platform Engineer

AWS | Terraform | Kubernetes | GitOps | CI/CD