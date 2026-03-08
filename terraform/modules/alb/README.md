# Module: ALB / Ingress

Defines ALB/Ingress related components (SG rules, ALB resources if managed outside controller, etc).

In many EKS setups, the AWS Load Balancer Controller creates ALBs dynamically; Terraform typically provisions:
- controller IAM (IRSA)
- security groups
- VPC/subnets tagging requirements
