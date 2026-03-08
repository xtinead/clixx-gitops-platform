# Terraform Modules

This folder contains reusable Terraform modules used by the Clixx GitOps Platform.

Modules are intentionally separated by responsibility to reduce blast radius and support environment-specific composition.

## Modules

- `vpc/` — VPC, subnets, routing, NAT (as needed)
- `eks/` — EKS cluster, managed node groups, cluster addons (as needed)
- `iam/` — IAM roles, policies, IRSA/OIDC plumbing
- `alb/` — ALB/Ingress-related infrastructure and security groups

> Note: This repository may include “portfolio-safe” module skeletons (interfaces + examples) rather than full production code.
