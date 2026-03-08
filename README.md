
📖 **Full platform documentation:** https://github.com/xtinead/clixx-gitops-platform

# Clixx GitOps Platform — AWS EKS + Terraform + Jenkins

Production-grade GitOps platform demonstrating infrastructure-as-code, pull-based Kubernetes delivery, CI/CD governance, and secure platform boundaries on AWS.

This repository represents a complete DevOps / Platform Engineering implementation using:

- Terraform (modular infrastructure as code)

- AWS EKS

- Argo CD (pull-based GitOps)

- Jenkins (CI/CD orchestration)

- IAM OIDC integration

- ALB Ingress Controller

- S3 + DynamoDB remote state

- Slack notifications

- Manual approval gates for production governance

## Executive Summary

This platform enforces strict separation between:

- CI orchestration (Jenkins)

- Infrastructure provisioning (Terraform)

- Runtime reconciliation (Argo CD)

Jenkins does not deploy directly to the Kubernetes cluster.
All runtime state flows through Git.

This ensures auditability, drift detection, and safe rollback via version control.

## 📌 Architectural Principles

- Git as the Single Source of Truth

- Pull-based deployments via Argo CD

- Jenkins isolated from cluster access

- Infrastructure and application delivery decoupled

- Manual approval required before production changes

- Rollback handled via Git revert

- Continuous drift detection via reconciliation

## 🏗 Platform Architecture
### High-Level Flow

1. Developer pushes or merges PR

2. GitHub webhook triggers Jenkins

3. Jenkins:

- Runs validation & lint checks

- Executes Terraform plan

- Requires manual approval

- Applies infrastructure changes

- Updates image tags / Helm values in GitOps repository

4. Argo CD detects Git change

5. Argo CD reconciles desired state to EKS

6. Health check validates deployment

7. Rollback occurs via Git revert if required

Architecture diagrams available in [Diagrams directory](diagrams).

## 🚀 CI/CD Delivery Flow

Jenkins acts strictly as an orchestration engine.

Pipeline stages:

- Checkout application & GitOps repositories

- Lint / validation

- Terraform init / validate / plan

- Manual approval gate

- Terraform apply

- Update image tags / Helm values in GitOps repo

- Slack notifications

Jenkins does not deploy to Kubernetes.
Deployment is triggered only through Git state changes.

See the [Jenkins directory](jenkins/).

## 🔁 GitOps Delivery Model

Argo CD continuously monitors the GitOps repository and reconciles:

- Desired state (Git)

- Live state (Kubernetes)

Capabilities include:

- Automatic reconciliation

- Drift detection

- Declarative configuration management

- Git-based rollback

- Immutable deployment history

See the [Gitops directory](gitops).

## 🔧 Terraform (Infrastructure as Code)

The Terraform implementation provisions:

- VPC & networking

- EKS cluster & managed node groups

- IAM roles & OIDC integration

- ALB Ingress configuration

- S3 + DynamoDB remote state backend

- Environment-aware module structure (dev / stage / prod ready)

Infrastructure is modular, reusable, and state-safe.

See the [Terraform directory](terraform).

## 🔐 Security Model

Security boundaries include:

- Jenkins isolated from cluster credentials

- IAM roles with least privilege

- OIDC integration for Kubernetes service accounts

- No long-lived cluster credentials in CI

- Manual approval before production changes

See /docs/platform-infra/security-model.md.

## 📊 Observability & Governance

- Post-deployment health checks

- Slack notifications for pipeline visibility

- Manual approval gate before infrastructure apply

- Git-based rollback strategy

- Drift detection via Argo CD reconciliation

## 📚 Documentation

Extended engineering documentation available in /docs:

- Platform evolution

- Infrastructure teardown & rebuild strategy

- GitOps flow

- Security model

- Lessons learned

## Why This Project Matters

This repository demonstrates:

- Platform-level architecture design

- Infrastructure governance controls

- Secure Kubernetes delivery patterns

- GitOps maturity

- CI/CD orchestration discipline

- Cloud-native systems thinking

This is not a tutorial implementation.
It reflects production-oriented platform engineering practices.

## Author

Christine Adelusi

Senior DevOps / Platform Engineer
AWS | Terraform | Kubernetes | GitOps | CI/CD