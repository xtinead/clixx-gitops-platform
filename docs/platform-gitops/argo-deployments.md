# Argo CD Deployments

Argo CD is deployed after EKS readiness is verified.

## Responsibilities
- Application lifecycle management
- Ingress creation
- Self-healing deployments

## Separation of Concerns
Argo CD does not:
- Create IAM roles
- Modify networking
- Touch AWS primitives
