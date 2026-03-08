# Module: VPC

Creates a VPC with public/private subnets and routing components required for EKS.

**Inputs (typical):**
- `name`, `cidr_block`
- `public_subnet_cidrs`, `private_subnet_cidrs`
- `enable_nat_gateway`

**Outputs (typical):**
- `vpc_id`
- `public_subnet_ids`
- `private_subnet_ids`
