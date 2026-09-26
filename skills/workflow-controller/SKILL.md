---
name: workflow-controller
description: Coordinate, resume, or determine the next permitted action for an AI-media project. Use for end-to-end starts—including 白板手绘动画、逐笔手绘、连续笔迹动画、图片分区连续笔迹渲染、线稿逐笔显现 or whiteboard_animator projects—continue/status requests, newly generated or edited media, real-media review or acceptance, dependency/version changes, staged approvals, quality-gated retries, and human escalation; do not fabricate evidence or invoke unapproved external actions.
---

# Workflow Controller

Coordinate the existing project Skills without replacing their authority. The controller observes a structured evaluation, validates it against hard constraints, selects one permitted next action, and persists the decision. It is deliberately bounded: it does not retry indefinitely, silently revise frozen semantics, or skip a mandatory Gate.

## Activation policy

Enter the Controller first when a request starts or resumes a full project, asks for status or the next step, reports generated/edited/accepted/rejected media, requests Review of real media, changes a Script/ADP/Prompt dependency or revision, confirms a staged Gate, proposes propagation to more Clips, or reports a conflict between files and machine state. Natural-language intent is sufficient when this Skill is available; an explicit plugin mention is a deterministic control, not a recurring requirement.

A bounded, read-only, specialist-only question may go directly to the owning Skill when it does not mutate project stage, artifact lineage, approval, or external-action state. If that Specialist creates a project artifact, records a formal Review, changes version/state, or recommends advancement, it must return through the contract below.

When a request could be either explanation or progression, check for a current project, Stage, real artifact, or external action. With no project impact, answer directly. With downstream impact, enter the Controller. Words such as “continue” or “complete” never override the current Gate or artifact evidence.

## Start and resume reconciliation

Run one bounded reconciliation when the Controller starts/resumes a project, receives a reported artifact or Specialist return, observes a dependency revision change, receives a next-step request, or detects a conflict between the user's statement and machine state.

Do not create or require a Video Adapter intake before creative planning. Use platform, model, output, reference, and audio facts already supplied by the user without turning them into a separate stage or artifact. Immediately before a cost-incurring generation request, include only the parameters that materially affect that request in the existing Cost Gate or call package: selected platform/model, duration, aspect ratio, relevant reference bindings, audio mode, quantity, and estimated cost when available. If the chosen execution surface does not expose a required control, keep only that field `UNKNOWN` and request a decision then. Do not infer wrapper capabilities from the underlying model.

For the optional local `whiteboard_animator` Renderer, record `local_cli`, exact Renderer/runtime versions, a checksum-bound source image plus optional checksum-bound RGBA tip, `native_audio: none`, and this video's confirmed `aspect_ratio`, `resolution`, `width_px`, and `height_px`; provider/model/duration-choice fields are not applicable rather than fabricated. Run its suitability preflight before render. A full-frame connected illustration without usable structured line art/layers returns `unsupported` or `human_review`; never route it as a successful diagonal reveal. Contract `1.1` may use explicit RGBA layers with independent draw/z order and either supplied `line_then_fill` or line-free `direct_fill`; verify the final composite against the bound source and never infer hidden pixels. Keep unresolved output geometry `UNKNOWN`; a formal local Job is blocked until confirmed. Local CPU execution itself needs no media-generation Cost Gate, but imported images still need existing provenance/rights intake and paid source-image generation still needs the existing Visual Baseline and exact image Cost Gate. This is not available through `external_prompt_only`.

For whiteboard contract `1.3`, observe the derived style-slice hash, source-template/Renderer/route/geometry/tip fingerprint, existing human Pilot evidence, and benchmark-backed render plan as decision evidence; do not create another Gate or state owner. A new or unmatched fingerprint permits only one representative Pilot and blocks propagation. An exact accepted fingerprint may be reused. Formal segments execute serially through `video-production`; a failed segment retains prior passed outputs, stops downstream, and returns to existing Execution State. Neither a technical Pilot nor a merged final can advance beyond `success_pending_human_review` without continuous human viewing.

Observe only, in order: the explicit project root and applicable instructions; `Progress.md` as a summary; `production_manifest.json` or the declared machine source; `execution-state.json`; the current unit's referenced Script, ADP, Prompt, Review, and media; the exact file reported by the user; and matching files under Manifest-declared asset roots. Do not scan unrelated directories, infer approval or quality from filenames, or rank Progress/Notion/conversation summaries above Manifest and real artifacts.

Record the observation only as evidence on the current decision record, with trigger, current unit, checked artifact paths, existence, declared/observed version and hash, status, approval evidence, dependency match, drift, evidence refs, and confidence. It is not a second persistent state source. Missing/unreadable artifacts or unknown schema/hash/version block for evidence without consuming retry. A changed dependency makes the prior Review stale through existing lineage rules and also consumes no retry.

For newly reported managed-production media, route exactly one `video-production` media-intake action when Manifest lacks a unique target, revision, and SHA-256 binding. Intake may verify the named path, readability, media type and checksum, bind it to an existing target/revision, and record an existing pending/observed state. It must not create `actual_end_state`, QA PASS, human approval, selected media, a second Manifest, or a new Gate. After intake, return here and re-observe. Only uniquely bound managed media may route to `production_qa`; ambiguous target/revision/checksum blocks for evidence or human clarification.

## Mandatory staged approvals

Read [Staged Approval Gates](contracts/staged-approval-gates.md) for every end-to-end content run. The controller must stop after the script architecture package (`Topic Theses`, `Hook Selection`, `H-C-E-R-M outline`) and wait for explicit Stage 0 approval. After that approval it may route to the visual test package (`Global visual DNA` plus exactly three image prompts: `主角`, `场景`, `Key Frame`) and must stop again. Only after Stage 1 approval may it compile the full production package and project it to Notion. Stage 1 approval is not paid-generation approval.

`workflow_mode: external_prompt_only` is a bounded exception for a user who will manually use an external execution surface. Keep the existing managed-production route unchanged. Record `workflow_mode`, the `strategy_decision`, available execution facts, input hash, bounded preflight summary, and package status on the existing Controller decision evidence; do not create a Manifest, state file, Gate, or Review schema. Recommend S1–S4 and ask once only when the user did not select one. The sole Fast Path Gate is that strategy choice. Explicit, complete S1/S2 content may route directly to `video-production`; missing topic, script, factual, or compact-direction content routes only to its existing owning Skill. Historical, health, science, current-affairs, and other evidence-dependent claims remain blocked until the factual text is evidenced. A Fast Path `pre_generation_prompt` PASS ends at `prompt_ready_for_external_use`: it never requests a Cost Gate, LookDev, Storyboard, Notion projection, provider call, or media QA.

Later user-reported media may activate one independent External Result Review only when its Fast Path Prompt Package, input hash, actual request parameters, and one-reference-one-role bindings are uniquely confirmed. First re-read the final local media path, checksum, and technical specification. The semantic reviewer reads the versioned Prompt Package and derives Must Hold, state target, and reference responsibilities from it; missing fields make only the affected semantic item `UNKNOWN`. It must not invent a Manifest binding, use local package hashes as proof of an external submission, write `actual_end_state`, or treat observed ending evidence as a continuity-ledger source. If Fast Path attribution is absent or contradictory, do technical checks only and request the exact binding or a human decision. Each completed external review returns exactly one recommendation—`accept_current_stop_optimizing`, `edit_or_reuse_failed_unit`, `request_new_master_take_prompt`, or `request_human_decision`—then stops; it neither consumes managed retry nor compiles a repair in the same action.

## Per-unit loop

1. Load a unit state and an [Evaluator Result](contracts/evaluator-result.md). A pre-generation prompt review may instead supply [Review Result v2.1](../video-production/contracts/review-result-contract.md); a current managed VOX Poster uses its v2.2 extension with explicit check results. The controller validates either against the applicable route before mapping into existing assessment meanings. The evaluator may be an LLM, deterministic check, or human, but its evidence and source must be recorded. Legacy VOX assessment or v2.1 Poster Review is diagnostic only and cannot advance a new managed Poster.
2. Apply [route policy](policies/route-policy.md) to select the next Skill/tool or to skip only an optional unit.
3. Apply the retry budget and semantic boundary from [Execution State](contracts/execution-state.md). Emit exactly one owning capability and one action: advance, retry, skip, block for evidence, request the exact Gate, accept/stop, edit/reuse, bind reported media, request a separate Cost Gate, or escalate to human review.
4. Persist the decision and run the selected atomic action. Stop before another Skill, Gate, unit, or external action; re-observe the resulting artifact before selecting anything else.

## Specialist return contract

A Specialist that produces a project-level result populates this logical turn-level envelope and stops cross-Skill progression:

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

Treat the envelope as internal coordination state. In an ordinary user-facing reply, do not serialize or append raw YAML/JSON and do not repeat the same facts in prose plus the envelope. Render only a concise human-readable summary of the outcome, artifact links, approval or blocker, decision-changing unresolved evidence, and one recommended next action. Show the serialized envelope only when the user explicitly requests machine-readable or debug details, or when a destination tool requires that exact structure.

The envelope is not a Manifest, database, retry ledger, approval, or proof of completion. Re-read every referenced artifact and approval before deciding. If the current surface cannot reliably re-enter the Controller, the Specialist records `awaiting_controller_resume` and stops; it never calls the next Specialist itself.

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

`scripts/decide-next-action.ps1` evaluates structured assessment/Review input and enforces the route's mechanical PASS invariants. Synthetic fixtures prove policy transitions and blockers, not real evaluator judgment, tool invocation, media quality, human acceptance or retry effectiveness.
