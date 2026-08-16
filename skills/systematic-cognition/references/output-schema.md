# Cognition Result Fields

A standard result contains at least the following fields:

| Field | Requirement |
|---|---|
| `topic` | The topic the user wants to understand |
| `question` | The restated research question |
| `conclusion` | A one-sentence conclusion |
| `core_claims` | Three to five core claims |
| `scope` | Boundaries for location, period, version, and object |
| `evidence` | A claim-level mapping from conclusion to source and direct support |
| `uncertainties` | Insufficient evidence, conflicts, and unverified items |
| `next_questions` | At most three questions for further research |

Use this structure for an evidence entry when practical:

```json
{
  "claim_id": "C-01",
  "claim": "A verifiable conclusion",
  "url": "https://example.com/source",
  "title": "Source title",
  "source_level": "A",
  "published_at": "2026-08-09",
  "checked_at": "2026-08-09",
  "support": "The content directly supporting the claim",
  "supporting_locator": "Heading, section, page, paragraph, or data field",
  "status": "confirmed"
}
```

`status` may be only `confirmed`, `inferred`, `disputed`, or `unverified`. Mark `inferred` content explicitly as inference in the response; never disguise it as a source quotation.

For `confirmed`, `url`, `title`, `checked_at`, `support`, and `supporting_locator` are all required. Do not reuse
one broad source row to certify several materially different claims. If a page is inaccessible or the quoted support
cannot be located, set the affected claim to `unverified` rather than preserving a confirmed citation.
