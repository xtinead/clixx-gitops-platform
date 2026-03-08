# Module: EKS

Creates an EKS cluster and managed node groups.

**Inputs (typical):**
- `cluster_name`, `cluster_version`
- `subnet_ids`
- `node_groups` (min/max/desired, instance types)

**Outputs (typical):**
- `cluster_name`
- `cluster_endpoint`
- `cluster_oidc_issuer_url`
