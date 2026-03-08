# Security Model

## IAM Boundaries
- Jenkins assumes a scoped execution role
- Terraform manages IAM declaratively
- Kubernetes access uses EKS OIDC

## Network Security
- Private subnets for nodes and databases
- Security groups scoped per component
- ALB used for controlled ingress

## GitOps Security
- Argo CD operates with namespace-scoped permissions
- No direct AWS access from GitOps workloads
