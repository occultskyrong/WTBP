# Candidate Scoring Model

Use this model only after opening the candidate's sources in the current session. It ranks adoption fitness, not intrinsic software quality or security approval.

## Formula

Score each component from 0 to its stated maximum and add them without hidden normalization:

| Component | Maximum | Evidence |
|---|---:|---|
| Scenario fit | 35 | Task/outcome fit 15; input-output and target fit 10; constraint and non-goal fit 10. |
| Source and maintenance | 25 | Publisher authority 10; active contributors observable in the last 180 days 5; commit frequency in the last 180 days 5; last commit or release recency 5. |
| Community adoption | 15 | Applicable skills.sh installs, GitHub stars/forks, and independent usage signals. |
| Integration and safety | 15 | License 4; fixed revision and valid Skill path 4; declared permissions and side effects 4; dependency/execution boundary 3. |
| Evidence completeness | 10 | Current opened primary sources 6; cross-checks and explicit missing-data handling 4. |

`total_score = scenario_fit + source_maintenance + community_adoption + integration_safety + evidence_completeness`

Do not reassign missing component weight. Show `unverified` and its zero-point impact. For a first-party integration with no meaningful public-adoption metric, state that the community component is not applicable and rank it only against candidates of the same type; do not compare it mechanically with marketplace Skills.

## Thresholds

- `<60`: reject for adoption; it may be listed only as an excluded reference.
- `60–74`: reference-only unless the user accepts the explicit gaps.
- `75–84`: suitable for human review or local adaptation.
- `85–100`: strong candidate for governed adoption review, never automatic installation.

Break ties by higher evidence confidence, then publisher authority, then lower permissions.

## Evidence Confidence

Report confidence separately from total score:

- **High**: every material metric has a current-session source, both fitness and maintenance are independently checked, and no critical permission/license/revision gap remains.
- **Medium**: source and task fit are verified, but one non-critical maintenance or adoption metric is unavailable.
- **Low**: a critical metric is unavailable, only a single weak source is accessible, or the candidate cannot be safely compared.

Never infer confidence from model certainty, search volume, star count, or source count alone.

## Raw-Metric Disclosure

For each candidate include URLs and check date for: publisher, source type, install count when applicable, stars/forks, observable active contributors, 180-day commit count, latest commit/release date, license, fixed revision, Skill path, permissions, and side effects. Mark every unavailable value `unverified` with its reason.
