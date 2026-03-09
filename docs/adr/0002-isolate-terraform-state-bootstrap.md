# ADR-0002: Isolate Terraform State into a Bootstrap Layer

## Status
Accepted

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
Benefits:
- Protects Terraform state integrity
- Makes rebuild workflows safer
- Reduces risk of state loss during teardown

Tradeoffs:
- Adds an additional architecture layer
- Requires more deliberate environment bootstrapping