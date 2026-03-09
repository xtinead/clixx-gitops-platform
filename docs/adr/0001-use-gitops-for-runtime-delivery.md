# ADR-0001: Use GitOps for Runtime Delivery

## Status
Accepted

## Context
Traditional CI/CD pipelines often push deployments directly to Kubernetes using kubectl or Helm from the CI system.

This approach increases operational risk by:
- Granting CI direct cluster access
- Mixing CI orchestration with runtime delivery
- Reducing auditability of runtime state changes

## Decision
Use a pull-based GitOps delivery model with Argo CD.

Jenkins updates the GitOps repository, and Argo CD reconciles the cluster to the desired state defined in Git.

## Alternatives Considered
- Direct kubectl deployment from Jenkins
- Helm-based push deployment from CI
- Manual deployment workflows

## Consequences
Benefits:
- Git becomes the single source of truth
- Runtime changes are fully auditable
- Rollback can be handled via Git revert
- Drift detection is built into the delivery model

Tradeoffs:
- Additional GitOps repository structure is required
- Argo CD becomes a critical runtime component