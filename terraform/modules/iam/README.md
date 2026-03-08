# Module: IAM

Defines IAM roles/policies and OIDC integration for IRSA (IAM Roles for Service Accounts).

**Responsibilities:**
- EKS OIDC provider
- IAM roles for Argo CD / controllers
- Least privilege policies

**Outputs (typical):**
- `oidc_provider_arn`
- `role_arns`
