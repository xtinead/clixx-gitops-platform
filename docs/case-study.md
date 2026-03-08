# Case Study — Clixx GitOps Platform

## Problem

Traditional CI/CD pipelines often:

- Push directly to clusters

- Mix infrastructure and runtime state

-  rollback discipline

- Store cluster credentials in CI

This increases operational risk and configuration drift.

## Objective

Design a secure, production-style GitOps platform that:

- Separates infrastructure from runtime

- Uses pull-based reconciliation

- Enforces governance controls

- Enables safe rollback

- Maintains auditability

## Architecture Overview

The solution integrates:

- Terraform for infrastructure provisioning

- Jenkins for CI orchestration

- Argo CD for pull-based deployment

- EKS as Kubernetes runtime

- S3 + DynamoDB for state safety

- IAM OIDC for secure access

## Key Design Decisions

- Jenkins does not deploy directly to cluster

- Git is the deployment trigger

- Terraform apply gated by approval

- Rollback performed via Git revert

- Drift handled by Argo CD reconciliation

## Challenges Solved

- Eliminated direct cluster access from CI

- Reduced infrastructure drift

- Improved rollback safety

- Separated infra and runtime responsibilities

- Implemented environment isolation

## Outcome

The platform demonstrates:

- Secure GitOps delivery model

- Infrastructure governance discipline

- Modular Terraform architecture

- Production-safe CI/CD orchestration

This project represents a production-style DevOps platform implementation.