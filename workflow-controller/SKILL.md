---
name: workflow-controller
description: Coordinate, resume, or determine the next permitted action for an AI-media project. Use for end-to-end starts, continue/status requests, newly generated or edited media, real-media review or acceptance, dependency/version changes, staged approvals, quality-gated retries, and human escalation; do not fabricate evidence or invoke unapproved external actions.
---

# Workflow Controller

Coordinate the existing project Skills without replacing their authority. The controller observes a structured evaluation, validates it against hard constraints, selects one permitted next action, and persists the decision. It is deliberately bounded: it does not retry indefinitely, silently revise frozen semantics, or skip a mandatory Gate.

## Activation policy

Enter the Controller first when a request starts or resumes a full project, asks for status or the next step, reports generated/edited/accepted/rejected media, requests Review of real media, changes a Script/ADP/Prompt dependency or revision, confirms a staged Gate, proposes propagation to more Clips, or reports a conflict between files and machine state. Natural-language intent is sufficient when this Skill is available; an explicit plugin mention is a deterministic control, not a recurring requirement.

A bounded, read-only, specialist-only question may go directly to the owning Skill when it does not mutate project stage, artifact lineage, approval, or external-action state. If that Specialist creates a project artifact, records a formal Review, changes version/state, or recommends advancement, it must return through the contract below.

When a request could be either explanation or progression, check for a current project, Stage, real artifact, or external action. With no project impact, answer directly. With downstream impact, enter the Controller. Words such as “continue” or “complete” never override the current Gate or artifact evidence.

## Start and resume reconciliation

Run one bounded reconciliation when the Controller starts/resumes a project, receives a reported artifact or Specialist return, observes a dependency revision change, receives a next-step request, or detects a conflict between the user's statement and machine state.

At the first start or resume of a project that intends to produce video, resolve a Video Adapter intake before creative-stage routing. If no current Adapter record exists, the Controller's one next action is to ask for and record the minimum execution facts: provider or platform and access route, exact model/version, target resolution, aspect ratio and available duration choices, reference-input modes, and the intended native-audio strategy. Keep unsupported or unanswered capabilities `UNKNOWN`; do not infer that a third-party surface exposes every capability of the underlying model. Reuse an already current, evidenced Adapter record instead of asking again.

Observe only, in order: the explicit project root and applicable instructions; `Progress.md` as a summary; `production_manifest.json` or the declared machine source; `execution-state.json`; the current unit's referenced Script, ADP, Prompt, Review, and media; the exact file reported by the user; and matching files under Manifest-declared asset roots. Do not scan unrelated directories, infer approval or quality from filenames, or rank Progress/Notion/conversation summaries above Manifest and real artifacts.

Record the observation only as evidence on the current decision record, with trigger, current unit, checked artifact paths, existence, declared/observed version and hash, status, approval evidence, dependency match, drift, evidence refs, and confidence. It is not a second persistent state source. Missing/unreadable artifacts or unknown schema/hash/version block for evidence without consuming retry. A changed dependency makes the prior Review stale through existing lineage rules and also consumes no retry.

For newly reported managed-production media, route exactly one `video-production` media-intake action when Manifest lacks a unique target, revision, and SHA-256 binding. Intake may verify the named path, readability, media type and checksum, bind it to an existing target/revision, and record an existing pending/observed state. It must not create `actual_end_state`, QA PASS, human approval, selected media, a second Manifest, or a new Gate. After intake, return here and re-observe. Only uniquely bound managed media may route to `production_qa`; ambiguous target/revision/checksum blocks for evidence or human clarification.

## Mandatory staged approvals

Read [Staged Approval Gates](contracts/staged-approval-gates.md) for every end-to-end content run. The controller must stop after the script architecture package (`Topic Theses`, `Hook Selection`, `H-C-E-R-M outline`) and wait for explicit Stage 0 approval. After that approval it may route to the visual test package (`Global visual DNA` plus exactly three image prompts: `主角`, `场景`, `Key Frame`) and must stop again. Only after Stage 1 approval may it compile the full production package and project it to Notion. Stage 1 approval is not paid-generation approval.

`workflow_mode: external_prompt_only` is a bounded exception for a user who will manually use an external execution surface. Keep the existing managed-production route unchanged. Record `workflow_mode`, the `strategy_decision`, Adapter evidence, input hash, bounded preflight summary, and package status on the existing Controller decision evidence; do not create a Manifest, state file, Gate, or Review schema. Recommend S1–S4 and ask once only when the user did not select one. The sole Fast Path Gate is that strategy choice. Explicit, complete S1/S2 content may route directly to `video-production`; missing topic, script, factual, or compact-direction content routes only to its existing owning Skill. Historical, health, science, current-affairs, and other evidence-dependent claims remain blocked until the factual text is evidenced. A Fast Path `pre_generation_prompt` PASS ends at `prompt_ready_for_external_use`: it never requests a Cost Gate, LookDev, Storyboard, Notion projection, provider call, or media QA.

Later user-reported media may activate one independent External Result Review only when its Fast Path Prompt Package, input hash, actual request parameters, and one-reference-one-role bindings are uniquely confirmed. First re-read the final local media path, checksum, and technical specification. The semantic reviewer reads the versioned Prompt Package and derives Must Hold, state target, and reference responsibilities from it; missing fields make only the affected semantic item `UNKNOWN`. It must not invent a Manifest binding, use local package hashes as proof of an external submission, write `actual_end_state`, or treat observed ending evidence as a continuity-ledger source. If Fast Path attribution is absent or contradictory, do technical checks only and request the exact binding or a human decision. Each completed external review returns exactly one recommendation—`accept_current_stop_optimizing`, `edit_or_reuse_failed_unit`, `request_new_master_take_prompt`, or `request_human_decision`—then stops; it neither consumes managed retry nor compiles a repair in the same action.

## Per-unit loop

1. Load a unit state and an [Evaluator Result](contracts/evaluator-result.md). A pre-generation prompt review may instead supply [Review Result v2.1](../video-production/contracts/review-result-contract.md), which the controller validates and maps into the existing assessment meanings. The evaluator may be an LLM, deterministic check, or human, but its evidence and source must be recorded.
2. Apply [route policy](policies/route-policy.md) to select the next Skill/tool or to skip only an optional unit.
3. Apply the retry budget and semantic boundary from [Execution State](contracts/execution-state.md). Emit exactly one owning capability and one action: advance, retry, skip, block for evidence, request the exact Gate, accept/stop, edit/reuse, bind reported media, request a separate Cost Gate, or escalate to human review.
4. Persist the decision and run the selected atomic action. Stop before another Skill, Gate, unit, or external action; re-observe the resulting artifact before selecting anything else.

## Specialist return contract

A Specialist that produces a project-level result returns this turn-level envelope and stops cross-Skill progression:

```yaml
controller_return:
  source_skill: topic-hunter | script-engine | audiovisual-director | video-production | publishing-packaging
  task_scope: string
  outcome: complete | awaiting_user_confirmation | awaiting_controller_resume | blocked | human_review | no_change
  artifact_refs: [{path: string, artifact_type: string, version: string | null, status: string | null, sha256: string | null}]
  review_refs: [string]
  approval_state: {stage: string | null, status: string | null, evidence_ref: string | null}
  unresolved_evidence: [string]
  external_actions: {requested: [string], authorized: [string], still_not_authorized: [string]}
  recommended_next_action: string
  controller_reobserve_required: true
```

The envelope is not a Manifest, database, retry ledger, approval, or proof of completion. Re-read every referenced artifact and approval before deciding. If the current surface cannot reliably re-enter the Controller, the Specialist returns `awaiting_controller_resume` and stops; it never calls the next Specialist itself.

## Hard limits

- Every `retry` requires a named remediable failure and evidence; default maximum is two retries per unit.
- Any semantic change, ambiguous evidence, unsupported tool request, or exhausted retry budget routes to human review.
- Required Gates never become `skip`; evidence-dependent topics block and route to `research` before scripting.
- Production generation remains subject to the existing LookDev and user cost Gate. A controller decision cannot grant external-generation approval.
- Notion projection remains blocked until the Stage 1 visual-test confirmation is recorded. A successful local fixture or compiled package cannot substitute for either human confirmation.
- The controller routes; it does not claim that an LLM actually judged an artifact unless the evaluation result identifies the model/run and supplied evidence.
- A prompt Review `PASS` advances only to the independent Cost Gate request. It never calls a provider, and fixture-only Review Results remain withheld.
- The preceding Cost-Gate rule applies only to managed production. An `external_prompt_only` package may use one bounded `pre_generation_prompt` check with the existing feasibility/continuity/story-function meanings, including Duration Fit; retain its evaluator summary as Controller decision evidence rather than manufacturing a full-production Review Result or Manifest entry.

## Local verification

`scripts/decide-next-action.ps1` evaluates structured fixture assessments only. It proves policy transitions, not real LLM judgment, tool invocation, media quality, or retry effectiveness.
