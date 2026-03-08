# Teardown & Rebuild Strategy

The platform is intentionally designed to support full teardown and rebuild without orphaning resources.

## Destroy Order
1. platform-gitops
2. platform-infra
3. bootstrap (never destroyed)

## Safety Controls
- Jenkins confirmation gates
- Explicit destroy flags
- RDS `prevent_destroy` by default
- Snapshot-based recovery

## Why This Matters
Partial Terraform failures are common in real systems.  
This design ensures the platform can recover safely without manual AWS cleanup.
