---
name: systematic-cognition
description: Research a public topic through an evidence-first workflow and produce concise, structured, traceable understanding. Use when users ask to understand a topic systematically, search and summarize a question, search the web, provide accurate sources, avoid fabrication, or separate facts from inference.
---

# Systematic Cognition

Use this Skill to turn a natural-language topic into verifiable questions, sources, and conclusions. Related Practice: `product.evidence-first-cognition`.

## Operating Boundaries

- Interpret “search the entire web” as searching the publicly accessible web available in the current environment; never claim to exhaust the internet.
- Search live for current or fast-changing information, policies, prices, public figures, product capabilities, and security-related facts. Do not rely on unverified memory.
- Do not present unsupported content as fact. If a page cannot be accessed, state the limitation instead of filling gaps with model memory.
- Treat a source as usable only after the current session successfully opens it. If search is empty or page opening is unavailable, do not cite remembered URLs or present remembered facts as confirmed; report the research as incomplete and identify the needed source.
- Prefer official material, laws and regulations, standards, papers, primary data, company announcements, and original-author material. See [source-policy.md](references/source-policy.md) for detail.
- By default, provide only what the user needs to reach understanding; avoid unnecessary background, jargon, and unrelated links.

## Input Contract

Extract from the request:

- Topic and user goal: understand, compare, decide, explain, or verify.
- Scope: location, industry, version, period, target object, and technology stack.
- Depth: standard by default; expand to deep research only when requested.
- Output preference: summary, table, timeline, option comparison, or action recommendation.

When a missing detail will not change the conclusion, state the assumption and continue. When it would materially change the conclusion, ask only the one most necessary clarifying question.

## Workflow

1. Restate the research question in one sentence and list at most five subquestions.
2. Plan a small set of searches: definition or mechanism, first-party or primary sources, independent cross-checks, and counterexamples or disputes when necessary.
3. Use available web search and page-opening tools. Open primary pages first and record only sources successfully opened in the current session; do not treat search-result snippets as final evidence.
4. If search or page opening is unavailable or returns no usable source, stop the affected research branch: do not reconstruct citations from memory, mark affected claims `unverified`, and state the missing source or access limitation.
5. For every important conclusion, record the directly supporting source, publication date or access date, source level, and applicable scope.
6. Compare independent sources. When they conflict, present both sides, explain possible timing or definition differences, and do not silently resolve the conflict.
7. Separate content into confirmed facts, inferences from facts, and unverified or disputed points. Mark every inference explicitly.
8. Check citation integrity: every key claim maps to a reviewable original URL, title, source level, date, and the concrete supporting passage or location. A source title, search snippet, or nearby link alone is not support.
9. Check the output: key conclusions have sources, sources actually support the conclusion, current facts have dates, and no sources, figures, quotations, or certainty claims are fabricated.

## Output Contract

Respond in the user's language; use Chinese by default for this repository. Keep standard-depth output to one or two screens unless the user requests more detail:

```markdown
# Topic

## One-sentence conclusion

## Core understanding
1. ...
2. ...
3. ...

## Structure, mechanism, or key differences

## Applicability boundaries

## Evidence
| Claim | Source | Source level | Date | Status |
|---|---|---|---|---|

## Uncertainties and unverified items

## Next questions
```

Output rules:

- Provide three to five core insights by default; each should express one verifiable proposition where possible.
- Place citations beside the supported fact; do not collect untraceable links at the end.
- When evidence is insufficient, say so and specify what evidence is needed.
- Do not represent search volume, source count, or model confidence as factual accuracy.
- For summary-only requests, keep the one-sentence conclusion, core understanding, evidence, and uncertainties.

### No-source failure mode

When the current session cannot successfully search and open a direct source for the requested factual claims, stop before
writing a substantive conclusion. Return only: `Research incomplete`, the unavailable capability or source, the affected
claims as `unverified`, and the exact primary sources needed to continue. Do not include remembered facts, dates,
versions, quotations, URLs, or a “best effort” summary unless the user supplied that material in the request. A knowledge
cutoff disclaimer does not make remembered content usable evidence.

## Tools and Side Effects

- Use only the search, page-opening, and page-location capabilities needed for research. Do not install software, log in, download executables, or modify external systems to gather material.
- When code, files, or Figma work is needed, treat this cognition result as input to a later deliverable; the evidence standard remains unchanged.
- When preserving historical cognition, record the topic, query, sources, conclusions, check date, and unverified items. Do not turn one search result into permanent truth.

## Completion Gate

- Current or high-impact claims have live, directly supporting sources with date, scope, and a claim-level support record; facts, inferences, and unverified items are separated.
- When current-session source access fails, the response uses the no-source failure mode; any remembered factual detail or remembered URL is a gate failure.
- Search-result snippets, memory, or source count are never used as proof; inaccessible or conflicting evidence is disclosed.
- The output includes the requested depth, citations, uncertainties, and next questions; otherwise report the research as incomplete.
