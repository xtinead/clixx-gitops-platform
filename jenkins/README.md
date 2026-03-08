# Jenkins CI/CD Orchestration — Clixx Platform

This directory defines the CI/CD orchestration layer for the Clixx GitOps Platform.

Jenkins acts as an automation engine responsible for validation, infrastructure provisioning, and GitOps repository updates.

Jenkins does not deploy directly to the Kubernetes cluster.

## Role of Jenkins in This Architecture

Jenkins is responsible for:

- Source validation and CI checks

- Infrastructure planning and application via Terraform

- Enforcing governance through approval gates

- Updating GitOps manifests (image tags / configuration)

- Sending deployment notifications

Jenkins does not have direct kubectl access to the cluster.

Cluster reconciliation is handled exclusively by Argo CD.

## Pipeline Overview

High-level pipeline stages:

1. GitHub webhook triggers Jenkins

2. Checkout application & GitOps repositories

3. Lint / validation checks

4. Terraform init & validate

5. Terraform plan

6. Manual approval gate

7. Terraform apply

8. Update GitOps repository (image tag / values)

9. Commit & push changes

10. Slack notification

The pipeline enforces separation between infrastructure provisioning and runtime deployment.

## Governance & Approval Gates

Infrastructure changes are gated by manual approval before apply.

This ensures:

- Production safety

- Change visibility

- Controlled rollout

- Compliance alignment (if required)

Approval gates prevent uncontrolled terraform apply operations in production environments.

## Why Jenkins Does Not Deploy to Kubernetes

This platform intentionally avoids push-based deployment from CI.

Instead:

- Jenkins updates the GitOps repository.

- Argo CD detects changes.

- Argo CD reconciles desired state to the cluster.

Benefits:

- Eliminates direct cluster credentials in CI

- Reduces blast radius

- Improves auditability

- Enables Git-based rollback

- Enforces declarative delivery model

This separation is critical for secure GitOps implementation.

## Terraform Execution Model

Infrastructure changes follow this flow:

- terraform validate

- terraform plan

- Manual review of plan

- Manual approval gate

- terraform apply

All Terraform state is stored remotely using S3 + DynamoDB.

No local state is used for production infrastructure.

## GitOps Update Strategy

After successful infrastructure application:

- Jenkins updates image tags or configuration values

- Commits changes to GitOps repository

- Pushes commit to Git

This commit becomes the new desired state.

Argo CD handles cluster reconciliation.

## Security Considerations

- Jenkins does not store cluster-admin credentials

- AWS access controlled via IAM roles

- No long-lived static credentials

- Infrastructure changes gated by approval

- Git-based audit trail for all deployments

Jenkins is intentionally scoped to orchestration responsibilities only.

## Observability & Notifications

Pipeline outcomes are communicated via Slack notifications.

Notifications include:

- Success status

- Failure details

- Approval prompts

- Apply completion

This ensures operational visibility across environments.

## Failure & Rollback Handling

Failure handling follows two models:

Infrastructure Failure:

- Pipeline fails during validation or apply

- No GitOps changes are committed

Application Failure:

- Argo CD health check fails

- Rollback occurs via Git revert

- Argo CD reconciles cluster to previous state

Rollback is version-controlled and auditable.

## Why This Jenkins Design Matters

This implementation demonstrates:

- CI/CD governance maturity

- Secure separation between CI and runtime

- Infrastructure as code discipline

- GitOps integration awareness

- Production-safe deployment strategy

This is not a simple build-and-push pipeline.
It is a controlled orchestration layer within a GitOps platform.