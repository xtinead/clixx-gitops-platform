# Clixx GitOps Kubernetes Platform on AWS

A production-grade, fully automated GitOps platform built on AWS EKS with Terraform, Jenkins, and ArgoCD.

## 🔥 Highlights
- One-click environment rebuild
- Fully automated destroy (no manual AWS cleanup)
- GitOps-driven application lifecycle
- Safe RDS lifecycle management with snapshots
- Production-style networking and security

## 🧱 Architecture
![Architecture Diagram](diagrams/architecture.png)

## 🔁 CI/CD Pipelines
| Pipeline | Purpose |
|-------|--------|
| Terraform Infra | Provision & destroy AWS infrastructure |
| CI Docker | Build & push immutable images |
| GitOps | Validate and deploy via ArgoCD |

## 🧨 Destroy & Rebuild
![Destroy/Rebuild Diagram](diagrams/destroy-rebuild.png)

The platform supports cost-saving teardown while remaining 100% reproducible.

## 📂 Documentation
- [Architecture](docs/architecture.md)
- [Destroy & Rebuild](docs/destroy-rebuild.md)
- [Pipeline Walkthrough](docs/pipeline-walkthrough.md)
