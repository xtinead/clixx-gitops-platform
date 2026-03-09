# ADR-0003: Prevent Jenkins from Deploying Directly to Kubernetes

## Status
Accepted

## Context
A common CI/CD anti-pattern is granting Jenkins direct access to the Kubernetes cluster for deployment operations.

This increases the blast radius of CI credentials and makes the CI system a direct runtime control plane.

## Decision
Jenkins will not hold direct kubectl access to the cluster.

Instead:
- Jenkins performs validation and infrastructure actions
- Jenkins updates GitOps manifests
- Argo CD reconciles the cluster

## Alternatives Considered
- Jenkins using kubectl directly
- Jenkins using Helm directly against the cluster
- Manual cluster deployment after CI completion

## Consequences
Benefits:
- Reduces credential exposure
- Strengthens separation of concerns
- Aligns with GitOps principles
- Improves auditability of runtime changes

Tradeoffs:
- Deployment flow involves an extra reconciliation step
- Troubleshooting spans both CI and GitOps components