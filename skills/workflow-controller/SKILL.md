---
name: workflow-controller
description: Run a bounded observe-decide-act loop across topic, script, direction, and production stages from structured assessment evidence. Use for conditional routing, quality-gated retries, optional-step skipping, and human escalation; do not fabricate LLM evaluations or invoke unapproved external generation.
---

# Workflow Controller

Coordinate the existing project Skills without replacing their authority. The controller observes a structured evaluation, validates it against hard constraints, selects one permitted next action, and persists the decision. It is deliberately bounded: it does not retry indefinitely, silently revise frozen semantics, or skip a mandatory Gate.

## Mandatory staged approvals

Read [Staged Approval Gates](contracts/staged-approval-gates.md) for every end-to-end content run. The controller must stop after the script architecture package (`Topic Theses`, `Hook Selection`, `H-C-E-R-M outline`) and wait for explicit Stage 0 approval. After that approval it may route to the visual test package (`Global visual DNA` plus exactly three image prompts: `主角`, `场景`, `Key Frame`) and must stop again. Only after Stage 1 approval may it compile the full production package and project it to Notion. Stage 1 approval is not paid-generation approval.

## Per-unit loop

1. Load a unit state and an [Evaluator Result](contracts/evaluator-result.md). A pre-generation prompt review may instead supply [Review Result v2.1](../video-production/contracts/review-result-contract.md), which the controller validates and maps into the existing assessment meanings. The evaluator may be an LLM, deterministic check, or human, but its evidence and source must be recorded.
2. Apply [route policy](policies/route-policy.md) to select the next Skill/tool or to skip only an optional unit.
3. Apply the retry budget and semantic boundary from [Execution State](contracts/execution-state.md). Emit exactly one action: advance, retry, skip, block for evidence, or escalate to human review.
4. Persist the decision and run the selected action. Re-observe the resulting artifact before the next iteration.

## Hard limits

- Every `retry` requires a named remediable failure and evidence; default maximum is two retries per unit.
- Any semantic change, ambiguous evidence, unsupported tool request, or exhausted retry budget routes to human review.
- Required Gates never become `skip`; evidence-dependent topics block and route to `research` before scripting.
- Production generation remains subject to the existing LookDev and user cost Gate. A controller decision cannot grant external-generation approval.
- Notion projection remains blocked until the Stage 1 visual-test confirmation is recorded. A successful local fixture or compiled package cannot substitute for either human confirmation.
- The controller routes; it does not claim that an LLM actually judged an artifact unless the evaluation result identifies the model/run and supplied evidence.
- A prompt Review `PASS` advances only to the independent Cost Gate request. It never calls a provider, and fixture-only Review Results remain withheld.

## Local verification

`scripts/decide-next-action.ps1` evaluates structured fixture assessments only. It proves policy transitions, not real LLM judgment, tool invocation, media quality, or retry effectiveness.
