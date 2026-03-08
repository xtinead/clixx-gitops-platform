# Pipeline Design Decisions — Clixx GitOps Platform

This document explains key architectural decisions made in the Jenkins CI/CD pipeline.

## Why Jenkins Does Not Deploy to Kubernetes

This platform intentionally avoids push-based deployment from CI.

Instead:

- Jenkins updates GitOps manifests.

- Argo CD reconciles desired state.

- The cluster pulls changes from Git.

This prevents:

- Direct cluster credential exposure

- Accidental runtime modifications

- CI-driven configuration drift

## Why Manual Approval Exists Before terraform apply

Infrastructure changes affect:

- Networking

- IAM permissions

- Cluster configuration

- Load balancer exposure

A manual approval gate ensures:

- Production safety

- Change visibility

- Controlled rollouts

- Audit alignment

This mimics enterprise governance controls.

## Why Git Is the Deployment Trigger

Updating the GitOps repository:

- Creates immutable deployment history

- Enables Git-based rollback

- Allows promotion via PR workflow

- Separates CI from runtime

Git becomes the authoritative desired state.

## Why Terraform and GitOps Are Decoupled

Terraform governs:

- Infrastructure state

GitOps governs:

- Application runtime state

This separation:

- Reduces blast radius

- Prevents mixed concerns

- Simplifies rollback boundaries

## Failure Handling Strategy

Infrastructure Failure:

- Pipeline stops before GitOps update.

Application Failure:

- Health check fails.

- Git revert restores previous state.

- Argo CD reconciles automatically.

Rollback is version-controlled.

This design reflects production-grade CI/CD governance and GitOps maturity.