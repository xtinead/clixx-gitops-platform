# ADR-0006: Separate Remote-State Foundations from Terraform Execution Identity

- **Status:** Accepted
- **Date:** October 2, 2026
- **Supersedes:** [ADR-0002](0002-isolate-terraform-state-bootstrap.md)

## Context

The original architecture described a permanent bootstrap layer that owned the Amazon S3 Terraform backend and DynamoDB locking table.

A later implementation and documentation review found that two distinct foundational concerns had been grouped under the word `bootstrap`:

1. remote-state services required before Terraform roots can initialize;
2. IAM execution identities required before Jenkins can manage infrastructure.

The current Terraform implementation consumes an existing S3 backend and DynamoDB lock table but does not declare resources that create them. The `terraform/bootstrap` root instead creates the workload-account Terraform execution role and scoped IAM-management permissions.

The cross-account DNS path has a similar identity bootstrap. The `terraform/dns-bootstrap` root creates a DNS-account execution role that is required before the routine DNS Terraform root can operate.

Keeping these concerns conceptually combined made the architecture documentation inaccurate and obscured the real trust and lifecycle boundaries.

## Decision

Treat the remote-state foundation and Terraform execution-identity bootstrap as separate architectural domains.

### Remote-state foundation

The Amazon S3 backend and DynamoDB locking table are externally established, long-lived prerequisites.

They must:

- exist before remote Terraform initialization;
- remain outside the replaceable platform-infrastructure lifecycle;
- survive ordinary teardown and disaster recovery;
- be protected through their own administrative and retention controls;
- use isolated state keys for independent Terraform roots and environments.

The current repository consumes these services but does not claim ownership of their creation.

### Workload-account identity bootstrap

The `terraform/bootstrap` root owns:

- the workload-account Terraform execution role;
- its assume-role trust relationship;
- scoped IAM-management permissions required by the platform;
- controlled role-passing permissions for supported AWS services.

It does not own the remote-state bucket or lock table.

### DNS-account identity bootstrap

The `terraform/dns-bootstrap` root owns:

- the DNS-account Terraform execution role;
- trust allowing the workload Terraform role to assume it;
- the external-ID condition;
- narrow IAM-management permissions for the runtime Route 53 role and policy.

It does not own the hosted zone or routine ExternalDNS runtime configuration.

### Routine operational roots

Jenkins may manage the following operational roots after the execution identities exist:

- `platform-infra`;
- `platform-gitops`;
- `dns-account`;
- `artifact-registry`;
- `data-protection`.

The identity bootstrap roots remain controlled administrative procedures because Jenkins cannot create the role that it must already assume.

## State Isolation

Each root and environment uses a separate backend key. Representative sanitized keys include:

```text
bootstrap/<environment>.tfstate
dns-bootstrap/<environment>.tfstate
dns-account/<environment>.tfstate
artifact-registry/<environment>.tfstate
platform-infra/<environment>.tfstate
data-protection/<environment>.tfstate
platform-gitops/<environment>.tfstate
```

The actual backend name and account-specific configuration are excluded from public documentation.

## Lifecycle Classification

| Domain | Lifecycle treatment |
|---|---|
| Remote-state foundation | Permanent external prerequisite |
| Workload identity bootstrap | Foundational administrative procedure |
| DNS identity bootstrap | Foundational administrative procedure |
| DNS runtime authorization | Shared; destruction blocked |
| Artifact registry | Shared; destruction blocked |
| Data protection | Shared; destruction blocked |
| Platform infrastructure | Environment-specific and replaceable |
| GitOps control plane | Environment-specific and replaceable |

## Required Safeguards

- Never include the remote-state foundation in ordinary platform teardown.
- Verify the expected backend and key before plan, apply, import, or destroy.
- Restrict bootstrap execution to approved administrative identities.
- Use temporary AWS STS sessions for routine Jenkins execution.
- Keep trust policies and role-passing permissions scoped to platform requirements.
- Prevent routine pipeline destruction of shared DNS, registry, and data-protection roots.
- Exclude credentials, role-session tokens, private keys, and backend-sensitive details from public documentation and logs.
- Review bootstrap changes separately because they modify the trust path used by later automation.

## Alternatives Considered

### Continue describing the backend as owned by `terraform/bootstrap`

Rejected because it contradicts the implementation and causes operators to misunderstand what a bootstrap apply creates.

### Add backend resources to the existing bootstrap state

Rejected for the current design because Terraform cannot safely initialize a remote backend that must be created by the same backend-dependent workflow without a separate migration procedure. It would also mix state-service ownership with execution-identity ownership.

### Manage bootstrap roots through the routine Jenkins selector

Rejected because Jenkins must already assume the workload execution role, and the workload role must already be trusted before it can assume the DNS execution role. This creates a circular trust dependency.

### Store operational state locally

Rejected because local state weakens collaboration, locking, auditability, recovery, and protection from workstation loss.

## Consequences

### Positive

- Documentation matches the deployed ownership model.
- Operators can distinguish backend prerequisites from IAM bootstrap.
- Teardown boundaries are easier to reason about and verify.
- Execution-role changes receive appropriate administrative scrutiny.
- Operational roots retain isolated state and reduced blast radius.
- Disaster recovery does not depend on recreating the backend or guessing the trust chain.

### Negative

- Initial environment creation requires documented administrative steps outside the routine pipeline.
- The remote-state foundation has an external ownership process that must be maintained separately.
- More lifecycle domains require more explicit documentation and onboarding.

### Mitigations

- Maintain an authoritative construction-order runbook.
- Record backend prerequisites without publishing account-specific values.
- Version and review bootstrap Terraform independently.
- Validate AWS caller identity before every bootstrap or operational action.
- Periodically test state access, role assumption, teardown, and recovery.

## Validation

The decision was validated through review of the current Terraform resources and Jenkins layer selector:

- the repository contains no S3 bucket or DynamoDB table resources for the backend;
- `terraform/bootstrap` creates the workload Terraform execution role and supporting IAM policy;
- `terraform/dns-bootstrap` creates the DNS Terraform execution role and scoped IAM-management policy;
- Jenkins manages the five operational roots only after those identities exist;
- the September 25, 2026 recovery exercise preserved remote state while rebuilding the runtime platform.

The resulting lifecycle model is documented in the [Terraform architecture](../../terraform/README.md), [platform architecture](../platform-infra/architecture.md), and [teardown and rebuild runbook](../platform-infra/teardown-rebuild.md).
