# Lessons Learned

These lessons come from designing, tearing down, recovering, and validating the Clixx GitOps platform. They reflect failures observed during a real rebuild rather than hypothetical recommendations.

## Infrastructure creation is not the same as service recovery

A successful Terraform apply proves that infrastructure resources can be created. It does not prove that the service has recovered.

The recovery was complete only after validating:

- the database restored from the intended snapshot;
- uploaded media returned from the EFS backup;
- the application PVC was bound and populated;
- secrets were available;
- Argo CD applications synchronized;
- public DNS resolved;
- application workflows loaded correctly;
- monitoring and autoscaling were operational.

**Engineering improvement:** Treat application, data, DNS, monitoring, and user-flow checks as formal recovery acceptance criteria.

## State ownership must survive disaster recovery

Restoring an AWS resource outside Terraform creates a state-ownership problem. If the restored EFS filesystem had not been adopted, Terraform could have created a new empty filesystem or treated the recovered resource as unmanaged.

The complete platform configuration could not perform the import before EKS existed because other resources and providers depended on unknown apply-time values. A minimal configuration connected to the same backend was required to adopt the filesystem safely.

**Engineering improvement:** Document and automate state adoption for resources restored through provider-native recovery services.

## Backup APIs have service-specific semantics

The first encrypted EFS restore failed because the restore metadata omitted `kmskeyid`. AWS Backup also restored the original data beneath a timestamped directory rather than directly at the filesystem root.

Both behaviors were valid service semantics, but they invalidated assumptions in the first recovery attempt.

**Engineering improvement:** Retrieve and inspect restore metadata before starting a job, validate encryption parameters, and inspect the restored filesystem read-only before copying data.

## Database and filesystem recovery require different strategies

RDS recovery used a protected encrypted snapshot selected during the Terraform rebuild. EFS recovery used AWS Backup, a restore job, state adoption, mount-target recreation, and a controlled copy into the application's dynamic PVC.

Using one generic “restore storage” procedure would have hidden important differences in lifecycle and ownership.

**Engineering improvement:** Define independent recovery workflows and acceptance criteria for each persistent-data domain.

## Destruction order is part of platform design

GitOps workloads needed to be pruned while the cluster and controllers still existed. RDS deletion protection required an explicit unlock. Platform infrastructure could be destroyed only after those dependencies were addressed.

The safe order was:

1. validate recovery sources;
2. prune runtime workloads;
3. destroy the GitOps foundation;
4. unlock RDS protection through a separate approval;
5. destroy platform infrastructure;
6. preserve bootstrap state and recovery artifacts.

**Engineering improvement:** Treat teardown as a supported platform capability with plans, approval gates, and post-destroy verification.

## CRDs create real plan-time dependencies

Terraform could not plan the Argo CD root `Application` before the Argo CD Helm release installed its CRD. A `depends_on` relationship alone could not solve a schema-discovery failure that occurred during planning.

The reliable solution was a two-phase bootstrap:

1. install the Argo CD foundation with the root application disabled;
2. wait for the CRD to become established;
3. plan and apply the repository secret and root application.

**Engineering improvement:** Separate CRD installation from custom-resource creation when the provider validates manifests during planning.

## GitOps ownership should match resource lifecycle

The media-regeneration Job is a one-time operation, not a continuously running desired-state object. Managing it like an ordinary Kubernetes resource created lifecycle and immutability problems.

Converting it to an Argo CD `PostSync` hook with `BeforeHookCreation` made its intent explicit and allowed safe recreation during later synchronizations.

**Engineering improvement:** Use hook or workflow semantics for finite operational Jobs and ordinary reconciliation for long-lived resources.

## Idempotency turns retries into a recovery feature

The EFS data-copy workflow wrote a completion marker after verifying the recovered content. On a later run, it detected the marker and verified the destination instead of copying everything again.

This prevented duplicate work and made interrupted pipeline runs safe to repeat.

**Engineering improvement:** Add durable completion markers, precondition checks, and verification paths to recovery scripts.

## Cleanup must follow Kubernetes dependency order

The temporary recovery PV did not finish deleting while its PVC still existed. The pipeline appeared successful functionally, but cleanup waited until timeout.

Changing the order to delete the recovery pod, then the PVC, and finally the PV resolved the problem.

**Engineering improvement:** Design cleanup around Kubernetes binding and ownership relationships, and make cleanup best-effort without hiding recovery failures.

## IAM role names are not immutable identities

ExternalDNS used a source-account IAM role to assume a Route 53 role in another account. Recreating the source role preserved its name but changed its AWS principal identity. The destination trust policy retained the deleted role's internal principal ID and denied access.

Reapplying the DNS-account Terraform layer replaced the stale identity with the recreated role ARN. ExternalDNS then reconciled 12 DNS records successfully.

**Engineering improvement:** Revalidate cross-account trust whenever a trusted IAM principal is recreated, even if its ARN text appears unchanged in configuration.

## DNS recovery includes resolver behavior

ExternalDNS and Route 53 had already recovered while the local resolver still returned an empty result because of negative caching. Public resolvers showed the new records first.

**Engineering improvement:** Test DNS through authoritative or independent public resolvers before treating a local lookup failure as a control-plane failure.

## Least privilege requires an operational path

The human Engineer role correctly could not create namespaces, persistent volumes, or recovery pods. That restriction protected the cluster, but recovery still required privileged Kubernetes actions.

The solution was not to grant the human role permanent administrator access. Controlled Jenkins workflows used the Terraform execution role for narrowly defined, logged lifecycle operations.

**Engineering improvement:** Pair least-privilege human access with auditable automation for exceptional administrative procedures.

## Credentials need an explicit post-bootstrap lifecycle

The Argo CD initial admin password existed briefly in a Kubernetes secret. The pipeline moved it to AWS Secrets Manager without printing it, tied the stored value to the cluster UID, and removed the initial secret afterward.

**Engineering improvement:** Treat bootstrap credentials as temporary artifacts with secure publication, rotation, and deletion steps.

## Observability is part of the recovery contract

The application could return HTTP 200 while the platform still had incomplete metrics, failed collectors, or missing autoscaling signals. Grafana, Prometheus, Metrics Server, and the HPA therefore formed part of the validation rather than an optional follow-up.

**Engineering improvement:** Require cluster, node, namespace, workload, and autoscaling evidence in the recovery sign-off.

## Documentation must capture failure paths

A short happy-path checklist would not have explained:

- the missing EFS KMS metadata;
- the minimal Terraform import configuration;
- the nested AWS Backup directory;
- the Argo CD CRD bootstrap boundary;
- the temporary PVC cleanup dependency;
- the stale cross-account IAM principal;
- the local DNS negative cache.

These are the details an operator needs during a real incident.

**Engineering improvement:** Maintain both a step-by-step [teardown and rebuild runbook](platform-infra/teardown-rebuild.md) and an evidence-focused [disaster-recovery validation report](disaster-recovery-validation.md).

## Final takeaway

A mature platform is not defined only by how quickly it can be deployed. It is defined by whether its ownership boundaries, protected data, credentials, dependencies, observability, and recovery procedures remain understandable under failure.

The exercise transformed teardown and rebuild from an undocumented risk into a tested platform capability—and converted each failure into a concrete automation or documentation improvement.
