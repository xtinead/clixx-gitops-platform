# Terraform Infrastructure — Clixx GitOps Platform

This directory contains the Infrastructure-as-Code implementation for the Clixx GitOps Platform.

Infrastructure is provisioned using modular Terraform design patterns with remote state management and environment separation.

## Infrastructure Overview

The Terraform implementation provisions:

- VPC and networking (public/private subnets, routing, NAT where applicable)

- Amazon EKS cluster

- Managed node groups

- IAM roles and policies

- OIDC integration for Kubernetes service accounts

- ALB Ingress resources

- Remote state backend (S3 + DynamoDB)

Infrastructure is designed to support GitOps-based application delivery using Argo CD.

## Design Principles

The Terraform architecture was built around the following principles:

- Modular and reusable components

- Environment isolation (dev / stage / prod ready)

- Remote state safety

- Least privilege IAM

- Idempotent provisioning

- Controlled infrastructure changes via CI approval gates

## Directory Structure

Example high-level structure:

terraform/
│
├── modules/
│   ├── vpc/
│   ├── eks/
│   ├── iam/
│   └── alb/
│
├── environments/
│   ├── dev/
│   ├── stage/
│   └── prod/
│
├── providers.tf
├── backend.tf
└── variables.tf


Modules encapsulate reusable infrastructure components.
Environments reference modules with environment-specific variables.

## Remote State Configuration

Terraform state is stored remotely using:

- Amazon S3 (state file storage)

- DynamoDB (state locking)

This ensures:

- Concurrent execution safety

- Prevention of state corruption

- Auditability of infrastructure changes

No local state is used in production environments.

## Environment Separation Strategy

Infrastructure is environment-aware.

Each environment:

- Uses isolated variable definitions

- Can target separate AWS accounts if required

- Can define separate VPC CIDR blocks

- Can apply different scaling parameters

This allows safe promotion workflows from dev → stage → prod.

## EKS & OIDC Integration

The EKS module provisions:

- Kubernetes control plane

- Managed node groups

- OIDC provider

OIDC integration allows:

- IAM Roles for Service Accounts (IRSA)

- Secure pod-level IAM permissions

- Elimination of static AWS credentials in cluster workloads

This is critical for secure GitOps operation.

## ALB Ingress & Networking

The infrastructure includes:

- Public-facing Application Load Balancer

- Ingress controller configuration

- Security group rules with least privilege

- Private subnets for worker nodes

Networking is structured to:

- Separate public and private workloads

- Restrict direct cluster exposure

- Control ingress at the ALB layer

## Governance & Change Control

Terraform execution is not manual.

Infrastructure changes are:

1. Triggered via Jenkins pipeline

2. Validated using terraform validate

3. Reviewed via terraform plan

4. Gated by manual approval

5. Applied only after approval

This prevents uncontrolled production changes.

## Rebuild & Teardown Strategy

The infrastructure was designed to support:

- Full environment teardown

- Safe rebuild using modular design

- Minimal blast radius

- Controlled state transitions

Teardown and rebuild scenarios are documented under /docs/platform-infra/.

## Security Considerations

- IAM policies scoped to least privilege

- No hardcoded credentials

- Remote state protected via S3 policies

- State locking via DynamoDB

- Approval gates before apply

- Jenkins does not store long-lived AWS root credentials

## Operational Considerations

- Infrastructure drift is minimized by Terraform state enforcement

- Runtime drift is handled separately by Argo CD

- Infrastructure and application concerns are intentionally decoupled

Terraform governs infrastructure state.
GitOps governs application state.

## Why This Matters

This Terraform implementation demonstrates:

- Modular infrastructure design

- Environment-aware configuration

- Secure IAM integration

- State management maturity

- Governance via CI approval gates

- Production-grade infrastructure patterns

This is not a single-file Terraform example.
It reflects structured, reusable, and controlled infrastructure design.