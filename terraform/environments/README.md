# Terraform Environments

Each environment composes shared modules with environment-specific variables.

Typical usage:
- `dev/` — rapid iteration, smaller node groups
- `stage/` — release candidate validation
- `prod/` — guarded changes via approval gates

Each environment should include:
- `backend.tf` (remote state)
- `providers.tf`
- `main.tf` (module composition)
- `terraform.tfvars.example` (safe example values)
