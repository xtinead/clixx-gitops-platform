📘 Platform Evolution & Architectural Decisions

This platform has gone through multiple intentional iterations as requirements around safety, reproducibility, and blast-radius control became clearer.

Below I document how and why the architecture evolved.
________________________________________

Phase 1 — Bootstrap + Platform (Initial Design)

What existed

•	A single Terraform “platform” layer
•	Bootstrap used to:
        o   Create S3 backend
        o   Create DynamoDB lock table
•	Platform handled:
        o   VPC
        o	EKS
        o	IAM
        o	GitOps components

Why this worked initially

•	Simple mental model
•	Fast to iterate
•	Suitable for early experimentation

Limitations discovered

•	Tight coupling between:
        o	AWS primitives
        o	GitOps tooling
•	Destroying platform risked:
        o	Losing backend
        o	Breaking GitOps unintentionally
•	Hard to reason about destroy order
•	No clear separation of infrastructure ownership
________________________________________

Phase 2 — Permanent Bootstrap Layer

Refactor decision

Bootstrap was made permanent and immutable.

Why

•	Terraform backend must outlive all environments
•	Backend should never be destroyed accidentally
•	Enables:
        o	Safe rebuilds
        o	Multi-environment expansion
        o	Disaster recovery

Outcome

•	Bootstrap now owns:
        o	S3 remote state bucket
        o	DynamoDB lock table
        o   Terraform IAM Execution Role
•	Bootstrap is:
        o	Run once
        o	Never destroyed
        o	Not part of CI destroy workflows
________________________________________

Phase 3 — Platform Split: platform-infra vs platform-gitops

Motivation

As GitOps and EKS matured, it became clear that not all platform concerns are equal.

New architecture

bootstrap (permanent)
   |
   v
platform-infra  → AWS primitives
   |
   v
platform-gitops → Kubernetes & delivery
________________________________________

platform-infra responsibilities

•	VPC & networking
•	EKS cluster
•	IAM roles & OIDC provider
•	RDS / EFS
•	Security groups

Key principle:

Owns AWS primitives and must exist before GitOps.
________________________________________

platform-gitops responsibilities

•	Argo CD
•	Kubernetes manifests
•	Application ingress
•	GitOps reconciliation

Key principle:

Consumes infra outputs but never mutates AWS primitives.
________________________________________

Why this separation matters

•	Prevents GitOps from:
        o	Creating IAM roles
        o	Modifying networking
        o	Affecting AWS control plane
•	Allows:
        o	Independent destroy/rebuild
        o	Safer blast radius
        o	Clear ownership boundaries
________________________________________

Phase 4 — Controlled Teardown & Rebuild

Problem discovered

•	Partial Terraform failures leave orphaned AWS resources
•	Destroying infra without safeguards is dangerous

Solutions implemented

•	Explicit destroy ordering:
    1.	platform-gitops
    2.	platform-infra
•	Safety gates in Jenkins:
        o	Manual confirmation
        o   Environment awareness
•	RDS protection:
        o	Snapshots
        o	prevent_destroy
        o	Explicit teardown flags

Result

The platform can now be:
•	Fully destroyed
•	Fully rebuilt
•	Recovered from partial failures
________________________________________

Key Engineering Takeaways

•	Infrastructure must be designed for failure
•	GitOps should not own cloud primitives
•	State isolation is non-negotiable at scale
•	Safe destroy is as important as safe deploy
________________________________________

Why This Matters in Production

This evolution mirrors real production systems where:

•	Requirements change
•	Safety becomes critical
•	Teams grow
•	Platforms must survive mistakes

________________________________________

Tag Releases

Each major refactor is captured via Git Tags 

•   git tag v1-monolith
•   git tag v2-permanent-bootstrap
•   git tag v3-split-infra-gitops
