# API Contract (`openapi.yaml`) — frozen v1.1

`openapi.yaml` is the **single transport contract both stacks code against**
(BIS §12.2, "Contract ownership"). It is authored **verbatim from BIS §5** under
the §5.1 conventions and frozen at **v1.1** (INFRA-007 / B-2).

## Governance (BIS §12.2)

- **Path-versioned** (`/v1`). Additive changes ship inside `/v1` **without** a
  version bump: new endpoints, new *optional* request/response fields, and new
  values on `x-extensible-enum` fields. Clients MUST decode non-strictly —
  tolerate unknown fields and unknown extensible-enum values.
- **Breaking changes ⇒ `/v2`.** Breaking = removing/renaming a field, changing a
  type or semantics, tightening validation, changing a status code, adding a
  *required* request field, or changing pagination/sort defaults. The
  **openapi-diff CI gate** (`tooling/openapi/openapi-diff.sh`) fails any breaking
  diff against the base contract.
- **Deprecation / sunset**: mark `deprecated: true` in the spec; runtime adds
  `Deprecation` + `Link: rel="successor-version"`; ≥6-month window; `Sunset`
  header ≥90d before removal, then `410 ENDPOINT_SUNSET`. Security-critical cuts
  use `426 APP_UPGRADE_REQUIRED`.
- **Errors** are RFC 7807 `application/problem+json` with `code` from the IRR §7
  registry (mirrored in `Problem.code` `x-extensible-enum`).

## Generated Dart client

The client is **regenerated per release** and **never committed** (output
`build/dart-client`, git-ignored). CI (the `contract` job) runs:

```sh
npx @openapitools/openapi-generator-cli generate -c contracts/openapi/dart-client-config.yaml
cd build/dart-client && flutter pub get && dart run build_runner build && dart analyze
```

## Local checks

```sh
npx @redocly/cli lint contracts/openapi/openapi.yaml     # validate
bash tooling/openapi/test/diff-gate.test.sh              # prove the gate blocks breaking changes
```

**Do not hand-edit generated clients.** Change the contract, regenerate. Any edit
here is a governance act — it must trace to a BIS §5 row or a §12.2 rule.
