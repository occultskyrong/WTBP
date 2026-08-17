---
name: motion-design
description: Define purposeful, accessible, and verifiable product motion for Figma or implementation. Use for motion personality, micro-interactions, state transitions, page transitions, loading/error feedback, choreography, or reduced-motion decisions without copying or binding WTBP to an external motion Skill.
---

# Motion Design

Design motion as a product behavior contract. Read [`../../knowledge/design-capability-selection.md`](../../knowledge/design-capability-selection.md), [`../../knowledge/design-principles.md`](../../knowledge/design-principles.md), and [`../../knowledge/design-workflow.md`](../../knowledge/design-workflow.md) before defining transitions. When selected by a Figma flow, link the motion decision and external-reference boundary to the parent `DCS-YYYYMMDD-VNN`. Static screenshots cannot prove motion acceptance.

## Hard safety and routing gate

- If the request is only a static copy, layout, or screenshot task, do not create a `MOTION` contract; complete the narrower request directly.
- If the request asks to install, authenticate, update, or execute an external motion Skill, or to write to Figma without review, stop and state: `不安装、不认证、不写入 Figma；人工评审未完成，不能进入 Figma 写入。`
- If the request asks to ignore `prefers-reduced-motion` or any equivalent accessibility preference, explicitly refuse that part and provide a reduced-motion fallback; never say that you will comply with ignoring it.
- Never call a write, edit, or file-creation tool in this Skill. Return the motion contract in the response unless an explicit downstream workflow declares and authorizes an artifact path.

## Input Contract

- Approved `PS` and `AGC` context, or a concise interaction brief with actor, trigger, current state, next state, and target terminal.
- The purpose of motion: feedback, orientation, continuity, hierarchy, status, or brand expression.
- Existing tokens, component states, timing constraints, performance limits, accessibility requirements, and reduced-motion policy.
- Optional external adapter such as LottieFiles motion principles or Figma motion tooling. Record source URL, fixed revision, license, permissions, and actual usage separately from WTBP decisions.
- Ask one blocking clarification only when the trigger, state transition, target, or safety/accessibility boundary is materially missing.
- When a required input is missing, do not invent a motion or default target. List every missing gate before clarifying: trigger, current/next state, target terminal, purpose, and reduced-motion/accessibility policy.

## Workflow

1. Map the state transition and user purpose. Reject decorative motion that has no communication, feedback, orientation, or approved brand role.
2. Define `MOTION-YYYYMMDD-VNN`: motion personality, trigger, target elements, property selection, duration range, delay/stagger, easing family, interruption behavior, and completion condition.
3. Specify choreography and implementation-independent behavior first. Then map it to Figma prototypes, CSS, Motion, GSAP, Lottie, or another declared target without making the implementation library the source of design intent.
4. Define reduced-motion behavior, pause/interrupt behavior, focus/keyboard implications, and fallback to a stable state. Check performance risk and avoid animating layout properties when a composited alternative communicates the same change.
5. Produce dynamic evidence: an exported video, timeline/keyframe record, or deterministic runtime capture. Use still images only for resting-state evidence; they cannot close a motion gate.
6. Obtain human review of timing, meaning, accessibility, and perceived quality. Hand off approved behavior to Figma implementation or `figma-to-product`; do not write the target in this Skill.

## Boundaries

- Do not add automatic or decorative animation merely to make a screen feel lively.
- Do not write to Figma, code repositories, or external services without explicit downstream authorization.
- Do not write drafts to WTBP, a consuming repository, or an undeclared temporary directory; local output requires an explicitly declared path and authorization.
- Do not install, authenticate, or silently update an external motion Skill; it is a replaceable adapter.
- Do not claim runtime smoothness, Figma prototype fidelity, accessibility, or reduced-motion support without the corresponding evidence.
- Stop when the trigger, state transition, target terminal, or reduced-motion requirement is materially missing.

## Output Contract

When a required gate is missing, return a blocking list before any optional suggestion:

```text
Missing motion gates
- trigger: missing
- current/next state: missing
- target terminal: missing
- purpose: missing
- reduced-motion/accessibility policy: missing
Motion definition: blocked pending the missing inputs and human review.
```

Return:

```text
MOTION revision, scope, and target terminal
Purpose and motion personality
Trigger/state transition matrix
Element/property selection, duration, delay/stagger, easing, interruption, completion
Reduced-motion and fallback behavior
Performance, focus, keyboard, and accessibility implications
External adapter source/revision/license/permission record, if used
Figma/implementation mapping
Dynamic evidence: video, timeline, keyframes, or runtime capture
Human review, unresolved decisions, and unverified boundaries
```

Unless explicit human-review evidence is supplied, include the exact status `人工评审：未完成，不能进入 Figma 写入`.

## Completion Gate

- Every motion has a stated user/product purpose and a trigger-to-state transition.
- Timing, easing, properties, choreography, interruption, completion, and reduced-motion fallback are explicit.
- The target implementation mapping and external dependency boundary are recorded separately from design intent.
- Dynamic evidence and human review exist; a static screenshot alone blocks completion.
- No unapproved automatic motion, external installation, credential use, or runtime claim is present.
