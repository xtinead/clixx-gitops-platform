# ADR-0004: Require Manual Approval Before Terraform Apply

## Status
Accepted

## Context
Infrastructure changes can affect networking, IAM, cluster availability, and external exposure.

Automatically applying Terraform in all cases can create unnecessary production risk.

## Decision
Require a manual approval gate before terraform apply is executed in the Jenkins pipeline.

This approval is enforced after terraform plan and before infrastructure changes are applied.

## Alternatives Considered
- Fully automated terraform apply
- Manual Terraform execution outside CI
- Separate pipelines for plan and apply without approval controls

## Consequences
Benefits:
- Improves production safety
- Supports governance and change review
- Reduces accidental infrastructure modification

Tradeoffs:
- Slower deployment workflow
- Requires human interaction for production changes