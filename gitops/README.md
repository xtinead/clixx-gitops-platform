# GitOps Implementation — Clixx Platform

This directory defines the desired state configuration for workloads deployed to the Clixx EKS cluster.

Deployment is managed using Argo CD in a pull-based GitOps model.

## GitOps Philosophy

This platform enforces the following GitOps principles:

- Git is the single source of truth

- The cluster pulls state from Git

- CI does not push directly to Kubernetes

- All runtime changes are version-controlled

- Rollback is performed via Git revert

-  is continuously detected and corrected

Jenkins updates Git.
Argo CD reconciles the cluster.

## Deployment Flow

1. Jenkins pipeline updates image tag or configuration in this repository.

2. A commit is pushed to the GitOps repository.

3. Argo CD detects the change.

4. Argo CD compares:

    - Desired state (Git)

    - Live state (Cluster)

5. If drift exists, reconciliation occurs.

6. Health checks validate deployment.

7. If unhealthy, rollback is performed via Git revert.

This ensures immutable and auditable deployments.

## Repository Structure

Example structure:

gitops/
│
├── apps/
│   ├── dev/
│   ├── stage/
│   └── prod/
│
├── argo-applications/
│   ├── app-of-apps.yaml
│   └── clixx-application.yaml
│
└── README.md

## Environment Separation

Each environment maintains:

- Separate manifest overlays

- Environment-specific image tags

- Environment-specific scaling configuration

- Isolated namespace configuration

Promotion between environments occurs via:

- Pull requests

- Controlled Git merges

- CI approval gates (when required)

There are no manual kubectl apply operations.

## Argo CD Configuration

Argo CD is configured using:

- Declarative application definitions

- App-of-apps pattern (optional)

- Automatic synchronization policies (environment dependent)

Argo CD performs:

- Continuous monitoring of repository

- Reconciliation when drift is detected

- Health evaluation of deployed resources

## Reconciliation & Drift Detection

Argo CD continuously compares:

- Desired State → Defined in Git

- Live State → Running in Kubernetes

If configuration drift occurs:

- Argo CD restores cluster state to match Git

- Unauthorized changes are overwritten

- Manual cluster edits are reverted

This protects against configuration drift and human error.

## Rollback Strategy

Rollback does not occur via Kubernetes rollback commands.

Instead:

1. A previous Git commit is identified.

2. The change is reverted.

3. Argo CD detects the revert.

4. Cluster state is reconciled back to the previous version.

This preserves a complete audit trail.

## Security Considerations

- Jenkins does not hold cluster-admin credentials

- Argo CD operates within defined RBAC scope

- IAM Roles for Service Accounts (IRSA) are used where required

- No direct manual runtime modifications are encouraged

All runtime changes must flow through Git.

## Observability

Argo CD provides:

- Application sync status

- Health state reporting

- Drift detection visibility

- Deployment history

Pipeline-level observability is handled by Jenkins and Slack notifications.

## Why This GitOps Model Matters

This implementation demonstrates:

- Pull-based deployment architecture

- Clear separation between CI and cluster

- Immutable, version-controlled runtime state

- Controlled promotion workflows

- Secure and auditable operations

This is not a push-based deployment pipeline.
It is a declarative, reconciled runtime model.