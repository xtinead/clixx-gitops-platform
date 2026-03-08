# Terraform Platform Refactor: From Monolith to Layered Architecture

## Background
The Clixx platform was originally built as a single Terraform stack managing AWS infrastructure, Kubernetes resources, and GitOps tooling. This enabled rapid end-to-end delivery but introduced lifecycle challenges as the platform matured.

## Problem Statement
As the platform grew, several issues emerged:
- Terraform provider dependency cycles (AWS ↔ Kubernetes ↔ Helm)
- Kubernetes finalizers preventing infrastructure teardown
- Orphaned AWS resources (ALBs, ENIs)
- Unsafe and unpredictable destroy operations during cost-saving teardowns

## Refactor Strategy
The platform was refactored into two independent Terraform layers:

### platform-infra
Responsible for long-lived infrastructure:
- VPC and networking
- EKS cluster and node groups
- IRSA and IAM roles
- ALB Controller and ExternalDNS
- Persistent services (RDS, EFS)

### platform-gitops
Responsible for Kubernetes workloads:
- ArgoCD installation
- Root App (App-of-Apps pattern)
- Application manifests and Helm charts
- Route53 records referencing existing hosted zones

The GitOps layer consumes infra outputs via Terraform remote state.

## Outcomes
- Eliminated Terraform provider cycles
- Enabled deterministic destroy/rebuild workflows
- Reduced cloud spend via safe teardown
- Improved platform maintainability and clarity
- Aligned architecture with real-world platform engineering practices

## Key Takeaway
This refactor mirrors how production platform teams evolve systems: start monolithic for speed, then decouple for stability, safety, and scale.
