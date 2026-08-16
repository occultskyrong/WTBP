# Curated External Capability Card Contract

Use this contract when retaining a user-approved public source. The source record preserves provenance; the capability card makes the source discoverable without installing it.

## Source Record

Add one `knowledge/external-sources.yaml` record with a stable `source.<publisher>-<repository>` ID. Record `url`, `publisher`, `trust`, `accessed_on`, `scope`, `credential_boundary`, `license`, `revision`, `skill_path`, and `quality_evidence`. When a fact cannot be publicly verified, set the field to `unverified` with a short reason. `quality_evidence` records the observed maintenance/community signal or the reason it is unverified.

## Capability Card

Add one `knowledge/external-capabilities.yaml` card linked by `source_id`. Required retrieval fields are one-line non-empty lists:

| Field | Meaning |
|---|---|
| `solves` | Concrete user problems and repeatable outcomes the source directly supports. |
| `not_for` | Counterexamples and ownership boundaries that prevent false matches. |
| `scenarios` | Concrete conditions under which the capability is appropriate. |
| `cases` | At least two representative Chinese task requests that should match later. |
| `inputs` | Conditions or artifacts needed before the capability is useful. |
| `outputs` | Artifacts, evidence, or decisions it can provide. |
| `technologies` | Named ecosystems, protocols, languages, or frameworks. |
| `targets` | Relevant terminal, environment, or delivery target. |
| `installation_status` | Always `uninstalled` for curation. |
| `keywords` | Short lexical aliases; never the only description of the capability. |

Default `status` is `candidate`, `adoption` is `reference-only`, and `availability` is `reference`. A later governed review may change these fields, but curation never creates an external route or installation instruction.

## Matching and Deduplication

- Search the canonical URL, source ID, fixed revision, and Skill path before adding a card.
- Treat the same repository with a distinct documented Skill path as a possible separate card, not a duplicate by default.
- Keep unknown fields explicit as `unverified`; do not infer them from stars, descriptions, or organization names.
- `wtbp` matches problems, scenarios, cases, technologies, targets, inputs, outputs, and `keywords`; exact `not_for` matches suppress a false candidate, then semantic selection remains with the current session.
