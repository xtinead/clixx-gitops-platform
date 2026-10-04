# ADR-0002: Isolate Terraform State into a Bootstrap Layer

- **Status:** Superseded
- **Superseded by:** [ADR-0006](0006-separate-state-foundation-from-execution-identity.md)

## Context

Terraform state storage is a critical dependency for infrastructure provisioning.

If the state backend is managed in the same lifecycle as the platform infrastructure, it can be accidentally destroyed during teardown, making rebuilds unsafe and recovery difficult.

## Decision

Create a permanent Bootstrap layer that owns:

- S3 state bucket
- DynamoDB state locking table

This layer is separated from platform infrastructure and is not destroyed during normal teardown workflows.

## Alternatives Considered

- Store Terraform state locally
- Manage backend resources in the same Terraform stack as platform infrastructure
- Recreate backend manually when needed

## Consequences

### Benefits

- Protects Terraform state integrity
- Makes rebuild workflows safer
- Reduces risk of state loss during teardown

### Tradeoffs

- Adds an additional architecture layer
- Requires more deliberate environment bootstrapping

## Supersession Note

The underlying requirement remains valid: remote state must be isolated from replaceable platform infrastructure and must survive teardown.

Implementation review later confirmed that the current `terraform/bootstrap` root does not create the S3 backend or DynamoDB locking table. It creates the workload-account Terraform execution identity. The backend resources are externally established, long-lived prerequisites consumed by the Terraform roots.

ADR-0006 replaces the ownership model in this ADR while preserving its state-isolation objective.
