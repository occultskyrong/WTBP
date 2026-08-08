# WTBP Agent Guide

WTBP stores scenario-bound decision knowledge for software and product work. It
is not a collection of universal answers or prompt fragments.

## When to use this repository

For a decision that has material technical, cost, security, compliance, or
reversibility trade-offs, use `skills/practice-search/SKILL.md` before making a
recommendation. Start with `registry/catalog.yaml`, then load only the relevant
Practice, evidence, and reference implementation.

## Required output

State the current scenario, missing decision variables, the Practice IDs used,
options and trade-offs, recommendation, evidence, remaining risks, and a
verification method. Do not treat `stale` or `deprecated` content as a default
recommendation.

## Contribution boundary

Keep project-specific facts in the consuming project's own instructions.
Contribute reusable decision knowledge here only when it has a stated scope,
counterexamples, traceable evidence, and a verification method. Follow
`CONTRIBUTING.md` and run `make validate` plus `make review-staged` before
committing.
