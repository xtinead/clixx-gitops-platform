# GitOps Delivery Flow

This platform uses Argo CD to continuously reconcile desired state from Git.

## Flow
1. Code pushed to Git
2. Argo CD detects changes
3. Kubernetes manifests are applied
4. Drift is automatically corrected

## Why GitOps
- Declarative delivery
- Auditable change history
- No imperative kubectl in pipelines
