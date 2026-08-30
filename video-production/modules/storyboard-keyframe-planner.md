# Storyboard and Keyframe Planner

Storyboard validates spatial and action feasibility rather than requiring a full image for every Shot. It is optional for low risk, recommended for medium risk, and required for high-risk multi-character blocking, fast action, complex space, high-energy multi-shot plans, or important transitions.

Run this planner inside Skill 4 only after Stage 1 approval and Scene/Clip planning. It is not a new Skill 3-to-4 state owner. Reuse the frozen Script, ADP, Scene/Clip refs, Production Manifest, Review Result, and Execution State; never create a Creative Handoff Snapshot.

## Applicability

Record `skip` only when production risk is low and no named trigger exists. Medium/high risk, multi-character blocking, complex space, important transitions, high-energy multi-shot plans, continuity-sensitive Turning Point/Payoff, a new visual template, or high-cost error propagation requires `retain` or human review. Store concrete reasons and evidence rather than a genre label.

## Risk-selected Plan

Do not require one Panel per Shot. Select only Panels that reduce a named risk or carry an explicitly assigned Hook, Turning Point, Payoff, spatial relation, action transition, or continuity handshake. Six, nine, and twelve are layout suggestions, not schema values.

Each Panel records its ID, Script/ADP/Scene/Clip refs, time range, narrative function, assigned story-function flags, named risk, visual event, composition, character position, action/expression, environment, mood, continuity notes, and allowed non-realistic aids. Upstream assignments are references; Storyboard may not invent or rewrite motives, choices, plot, or conclusions.

## Contact Sheet and repair

Compile one Contact Sheet first with [the Storyboard template](../templates/storyboard-contact-sheet-prompt.md). It must preserve reading order and identity/spatial anchors, simplify detail, exclude provider syntax, and stop after one sheet. A local compiler or Fixture never calls a provider.

Only a Review with a named `must_fix`, evidence, Panel ID, repair target, and owner may request a Single Panel repair. Preserve every non-target Panel by reference. A real Contact Sheet or repair call always requires a separate Cost Gate.

## Evidence and Review

Prompt preview, local file creation, or `fixture_only=true` remains `planned_awaiting_cost_gate` and cannot become READY. A real Storyboard Review requires immutable asset revision, media checksum, evidence refs, and current dependency hashes. Reuse Review Result v2.1 `previsualization_storyboard`; `PASS` projects to READY, a named non-semantic repair projects to REVISE, missing/stale evidence blocks without retry consumption, and semantic impact routes to human review.

Storyboard PASS advances only to Prompt planning. It does not approve a Visual Baseline, Prompt Preflight, Production generation, actual continuity, or publishing.

Use First Frame, End Frame, Transition Frame, and Continuity Resume Frame only where they reduce a named risk. A Resume Keyframe inherits inspected `actual_end_state`, not the ideal ADP state.

`Scene Setting` is a plot-free spatial baseline for topology, fixed objects, and coverage. `Key Frame` is a story/action reference. `Resume Frame` is a continuity reference derived from the ledger's observed state. These roles are not interchangeable and a Fixture never upgrades one role into another.
