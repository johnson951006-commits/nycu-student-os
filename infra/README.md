# `infra/` — Terraform skeleton (INFRA-010)

Everything in OPS §1.1 declared as code: per-env roots under `environments/`
instantiate the shared `modules/platform` (VPC + static-IP NAT, Cloud SQL PG16
HA, Memorystore Redis HA, Pub/Sub topics+DLQs, KMS `portal-cookies` key,
Secret Manager, 4 Cloud Run services, Global LB + Cloud Armor, Firebase).
State lives in a locked GCS backend per env (OPS §3.1).

## Workflow

```sh
cd infra/environments/dev        # or staging / prod
terraform init
terraform plan                   # CI gate: plans must be clean
terraform apply                  # gated per OPS §2 (prod: tag + approval)
```

One-time bootstrap per env (before first `init`): create the state bucket
`gsutil mb -l asia-east1 gs://nycu-os-tf-state-<env>` with versioning +
uniform access, and grant the deployer SA `roles/storage.objectAdmin` on it.

## FCM setup runbook (console steps — not expressible in Terraform)

Per environment, after `terraform apply` has created the Firebase project link:

1. **Firebase console** → the `nycu-os-<env>` project appears (created by
   `google_firebase_project`). Add an iOS app + an Android app matching the
   Flutter bundle ids for that flavor (FA — flavors dev/staging/prod).
2. **APNs key upload (DV1):** Apple Developer → Keys → create an APNs auth
   key (`.p8`) → upload to Firebase → Project settings → Cloud Messaging →
   Apple app configuration. FCM's APNs relay then delivers to iOS —
   the backend never talks to APNs directly (BIS §4.2).
3. **Service account → Secret Manager:** Firebase Project settings → Service
   accounts → generate a private key JSON. Store it, never commit it:
   `gcloud secrets versions add fcm-service-account --data-file=key.json
   --project=nycu-os-<env>` (the secret resource is declared in Terraform).
   Cloud Run mounts it as `FCM_SERVICE_ACCOUNT_JSON` (BIS §1.4 secrets flow).
4. **Verify reachability:** with the secret mounted, the `FirebaseFcmSender`
   adapter initializes and a dry-run `sendEach` to a known test token
   succeeds — this is the "FCM project reachable" acceptance check.

## Boundaries

- No secret VALUE ever lives in Terraform (references only, OPS §8).
- `system_settings` runtime knobs (feature flags, rate caps) are NOT infra —
  operators flip them without a deploy (OPS §2, load-bearing for incidents).
- Alert policies/dashboards (OPS §5.2) land with the observability tasks.
