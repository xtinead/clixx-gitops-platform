# ADR-0005: Allow Controlled Jenkins Access for Cluster Lifecycle Operations

- **Status:** Accepted
- **Date:** September 25, 2026
- **Supersedes:** [ADR-0003](0003-prevent-jenkins-direct-cluster-access.md)

## Context

Argo CD is the platform's pull-based application delivery engine. Jenkins orchestrates Terraform plans, approvals, applies, teardown, and disaster recovery.

A strict interpretation of the earlier policy prohibited all Jenkins access to the Kubernetes API. A full teardown and rebuild exercise demonstrated that this restriction prevented necessary lifecycle operations that cannot be performed by Argo CD after, during, or before destruction of its own control plane.

The required operations included:

- checking cluster and controller readiness;
- pruning Argo CD-managed resources before EKS destruction;
- inspecting an AWS Backup EFS restore through a read-only pod;
- copying recovered application data into a new dynamic PVC;
- waiting for the Argo CD `Application` CRD during two-phase bootstrap;
- publishing the initial Argo CD credential to AWS Secrets Manager;
- deleting the initial Kubernetes credential after publication.

The platform needed a controlled administrative path without weakening the pull-based delivery model or granting engineers permanent cluster-admin access.

## Decision

Jenkins may access the Kubernetes API for explicitly defined platform lifecycle, bootstrap, teardown, recovery, and verification operations.

Jenkins must not become the routine application deployment authority. Application manifests remain in Git and are reconciled by Argo CD.

## Authorized Jenkins operations

Jenkins cluster access is limited by pipeline intent to:

1. readiness checks for EKS and platform controllers;
2. GitOps pruning before cluster destruction;
3. Argo CD foundation and root-application bootstrap coordination;
4. temporary EFS inspection resources;
5. temporary EFS recovery and data-migration resources;
6. secure Argo CD bootstrap credential publication and cleanup;
7. post-apply and post-recovery verification.

These procedures must be documented, reproducible, and executed from version-controlled pipeline or script code.

## Prohibited Jenkins operations

Jenkins must not:

- act as the normal deployment path for Clixx application manifests;
- bypass Git to make persistent application configuration changes;
- compete with Argo CD for ownership of long-lived runtime resources;
- print Kubernetes secrets, Git credentials, database credentials, or decoded passwords;
- use a long-lived static kubeconfig credential;
- grant the human Engineer role cluster-admin access as a substitute for automation;
- run unreviewed administrative commands outside an approved lifecycle workflow.

## Access model

Jenkins assumes the Terraform execution role using temporary AWS STS credentials. The role has an EKS access entry associated with the cluster-admin access policy because recovery operations include cluster-scoped namespaces and persistent volumes.

Kubernetes authentication is generated through AWS EKS authentication using the temporary assumed-role session. No static Kubernetes client certificate or token is stored in Jenkins.

The human Engineer role remains associated with the cluster-wide EKS view policy. Engineers can inspect cluster state while privileged mutations occur through controlled and logged automation.

## Required safeguards

### Pipeline gating

- Lifecycle operations must use explicit action parameters.
- Destructive actions must require dedicated confirmation flags.
- Terraform apply and destroy must use saved plans and manual approval.
- RDS deletion-protection unlock must have a separate plan and approval.

### Credential protection

- Sensitive shell stages must disable command tracing.
- Temporary credential and kubeconfig files must use restrictive permissions.
- Temporary files must be deleted with exit traps.
- The Argo CD password must be published to AWS Secrets Manager without appearing in logs.
- The initial Argo CD Kubernetes secret must be removed after publication.

### Recovery-resource controls

- Inspection mounts must be read-only.
- Recovery namespaces, pods, PVs, and temporary PVCs must use predictable names.
- Temporary resources must be removed in dependency order.
- Data-copy operations must be idempotent and verify completion markers.
- Recovery must fail closed when the expected filesystem, snapshot, directory, or marker cannot be verified.

### Auditability

Jenkins logs must identify:

- source Git revision;
- selected layer, action, and environment;
- AWS caller identity;
- approval identity and timestamp;
- recovery source identifiers;
- verification results;
- cleanup outcome.

Sensitive values must be excluded.

## Alternatives considered

### Prohibit all Jenkins cluster access

Rejected because lifecycle and recovery procedures require Kubernetes mutations before Argo CD exists or after it is being removed. This would force undocumented manual administrator access.

### Grant engineers permanent cluster-admin access

Rejected because it expands standing privilege, reduces consistency, and moves critical recovery actions outside pipeline audit records.

### Use Argo CD for all recovery resources

Rejected because Argo CD cannot safely own resources needed to restore or destroy its own control plane, and temporary data-migration resources are not ordinary continuously reconciled application state.

### Create a separate recovery operator

Deferred. A dedicated operator could be appropriate at greater scale, but it would add operational complexity beyond the current platform requirements.

## Consequences

### Positive

- The platform has a repeatable administrative path for bootstrap, teardown, and recovery.
- Human standing privilege remains limited.
- Argo CD retains routine application ownership.
- Recovery actions are version-controlled and auditable.
- Temporary resources and credentials have defined cleanup lifecycles.
- Full teardown and rebuild can be completed without ad hoc cluster-admin intervention.

### Negative

- The Terraform execution role has significant cluster privilege.
- Jenkins becomes part of the recovery control plane.
- Pipeline code and scripts require careful review and testing.
- A compromised Jenkins execution path would have material cluster impact.

### Mitigations

- Use temporary assumed-role credentials.
- Restrict role assumption to the Jenkins automation identity.
- Require branch protection and code review for pipeline changes.
- Preserve manual approval for material changes.
- Keep runtime application delivery in Argo CD.
- Monitor access and retain Jenkins build records.
- Periodically review whether permissions can be narrowed further.

## Validation

The decision was validated during the September 25, 2026 recovery exercise. Jenkins successfully performed controlled EFS inspection, application-data restoration, two-phase Argo CD bootstrap, secure credential publication, and teardown/rebuild verification while the Engineer role remained read-only.

The operational details are documented in the [Jenkins orchestration guide](../ci-cd/jenkins-orchestration.md), and the complete lifecycle is documented in the [teardown and rebuild runbook](../platform-infra/teardown-rebuild.md).
