# Platform Infrastructure Architecture

The platform-infra layer owns all AWS primitives required to run workloads safely and reproducibly.

## Responsibilities
- VPC & subnet topology
- Internet & NAT gateways
- EKS control plane
- IAM roles and OIDC provider
- RDS and EFS
- Security groups

## Design Principles
- GitOps never mutates AWS primitives
- Infrastructure must exist before delivery
- State is isolated per environment

## Key Outputs
- EKS cluster name, endpoint, CA
- OIDC provider ARN
- VPC and subnet IDs
- RDS endpoint
- EFS ID

These outputs are consumed by the GitOps layer via Terraform remote state.
