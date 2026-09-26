# ADR-0003: Prevent Jenkins from Performing Routine Application Deployment

- **Status:** Superseded by [ADR-0005](0005-allow-controlled-jenkins-cluster-lifecycle-access.md)
- **Original decision:** Accepted
- **Superseded:** September 25, 2026

## Context

The platform was moving from push-based CI/CD toward pull-based GitOps. Allowing Jenkins to deploy application manifests directly with unrestricted `kubectl` access would have created two competing deployment authorities:

- Jenkins applying runtime resources imperatively;
- Argo CD continuously reconciling runtime resources from Git.

That overlap would weaken drift correction, rollback discipline, auditability, and the Git repository's role as the source of truth.

## Original decision

Jenkins would not perform routine application deployment directly to the Kubernetes cluster.

Application changes would follow this path:

1. a versioned manifest or image reference is committed to Git;
2. Argo CD detects the change;
3. Argo CD reconciles the declared state;
4. rollback occurs through Git history and subsequent reconciliation.

Human access would remain read-only wherever possible.

## Why this decision was refined

The original wording was interpreted as prohibiting all Jenkins interaction with the Kubernetes API. A full teardown and disaster-recovery exercise showed that some platform lifecycle operations cannot be delegated to Argo CD safely:

- workloads must be pruned before the cluster and Argo CD are destroyed;
- restored EFS data must be inspected and copied before the application resumes ownership;
- Argo CD bootstrap requires readiness and CRD checks;
- the initial Argo CD credential must be published securely and removed;
- recovery resources require temporary namespace, pod, PV, and PVC operations.

Granting permanent cluster-admin access to engineers was not an acceptable alternative.

## Superseding decision

[ADR-0005](0005-allow-controlled-jenkins-cluster-lifecycle-access.md) preserves the essential boundary established here:

- Jenkins does not become the routine application deployment engine.
- Argo CD remains the authority for application reconciliation.
- Jenkins may perform narrowly defined, auditable platform lifecycle and recovery operations through an assumed execution role.
- The human Engineer role remains read-only.

## Lasting consequence

The important control is not “Jenkins can never contact Kubernetes.” The important control is that every automation system has one clear responsibility and that privileged exceptions are explicit, limited, and auditable.
