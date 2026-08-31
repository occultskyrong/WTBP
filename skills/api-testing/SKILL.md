---
name: api-testing
description: Design and verify a four-layer HTTP API test system covering deployment reachability, real happy-path smoke, mocked logic and contract cases, and isolated business-flow chains. Use when API availability, real endpoint behavior, mock coverage, or CRUD workflow evidence must be planned or validated together.
---

# API Testing

Use this Skill to turn an API testing request into a bounded, evidence-backed four-layer test plan or execution report. Keep deployment reachability, real endpoint behavior, isolated logic tests, and multi-request business flows as separate evidence classes.

## Input Contract

- Required: target API/service scope, test objective, available environment(s), authentication boundary, and required evidence.
- Required for execution: API contract or endpoint inventory, standard requests, expected status/business codes, test-data scope, and cleanup policy.
- Optional: framework, runner, OpenAPI document, existing fixtures, dependency map, CI entrypoint, and risk labels.
- One blocking clarification: if the target environment or data-safety boundary is unknown, stop before any real write request and mark runtime evidence `Unverified`.

## Workflow

1. **Scope and inventory** — identify services, endpoints, caller identity, environment, side effects, criticality, and non-goals. Produce or reference stable API IDs.
2. **Contract baseline** — record method/path/auth, standard request, expected HTTP and business outcomes, response schema, preconditions, cleanup, and related flows. Do not infer missing values as facts.
3. **L1 availability probe** — run safe health/readiness and critical read-route probes against the declared deployment. Assert reachability, response type, minimum schema, auth boundary, and bounded latency. Report deployment evidence separately from business success.
4. **L2 real smoke** — call the deployed service over the real transport with standard parameters and real authentication. Assert HTTP status, business code, schema, essential invariants, and response correlation ID. Use only isolated or non-destructive data unless the write scope is explicitly approved.
5. **L3 mock logic and contract** — test the service with external dependencies mocked. Cover positive, invalid, boundary, auth, permission, not-found, timeout, dependency error, idempotency, concurrency, pagination, and illegal state cases. Validate provider/consumer schemas where a contract exists.
6. **L4 business flow** — run a stateful chain in an isolated tenant or unique test namespace. For CRUD, query only the scoped namespace, create, assert list increment, read detail, update, assert detail, delete, assert absence, assert list decrement, and clean up. Never require a shared environment to be globally empty.
7. **Classify and report** — classify failures as `DEPLOYMENT_UNAVAILABLE`, `CONTRACT_DRIFT`, `BUSINESS_FAILURE`, `AUTHORIZATION_FAILURE`, `TEST_DATA_FAILURE`, `DEPENDENCY_FAILURE`, or `TEST_INFRA_FAILURE`. Include API ID, environment, fixture/run ID, request ID, assertion, and first failing step.
8. **Handoff and gate** — map results to PR, merge, pre-deploy, post-deploy, nightly, or release gates. Record unverified runtime boundaries and the next authorized action.

## Four-layer gate

| Layer | Evidence | Typical gate | Must not claim |
| --- | --- | --- | --- |
| L1 | Real safe probe against deployed service | pre/post deploy | business flow is correct |
| L2 | Real HTTP request with standard parameters | post deploy/release | all branches are covered |
| L3 | deterministic mock, contract, and negative cases | PR/merge | deployment is healthy |
| L4 | isolated stateful multi-endpoint chain | merge/nightly/release | unrelated shared data is clean |

## Boundaries

- Do not call production write endpoints or mutate external systems without an explicit target, data boundary, and authorization.
- Do not call Mock or unit results real deployment evidence; do not call a generated report a runtime pass when the request did not run.
- Do not use shared mutable fixtures, global-empty assumptions, or unbounded retries to hide state and flakiness.
- Do not put credentials in manifests, fixtures, logs, reports, prompts, or source. Inject them through the declared test runner and redact responses.
- Do not add a framework or external dependency solely because this Skill was selected; choose the consuming project's existing runner or record an adoption decision.

## Output Contract

Return, in the user's language by default:

1. `Scope and assumptions` — service, environment, auth, data boundary, non-goals, and missing variables.
2. `API contract baseline` — stable IDs and expected outcomes.
3. `Four-layer matrix` — L1/L2/L3/L4 cases, real/mock boundary, fixtures, and gate.
4. `Execution evidence` — commands or runner, result, timestamps/version, request IDs, and reports.
5. `Failure classification` — first failure, assertion, evidence, and suspected owner.
6. `Unverified items and human decisions` — unavailable environments, write authorization, framework choice, and release approval.

Do not report a layer as complete when its declared runtime or human evidence is unavailable.

## Completion Gate

- The scope, environment, auth, data isolation, contract, and cleanup policy are explicit.
- All four layers are either executed with evidence or marked `Unverified` with a blocking reason.
- At least one positive and one negative case exist for every critical endpoint; each critical flow has ordered state assertions and cleanup.
- Mock evidence and real-runtime evidence are reported separately.
- Reports contain stable API IDs, fixture/run IDs, request IDs, assertion results, and first-failure classification.
- CI/release gates and remaining human confirmation points are explicit.
