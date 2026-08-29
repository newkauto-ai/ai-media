# Staged Approval Gates v1.0

The AI-media workflow is human-gated in three stages. A stage is not complete because a
downstream artifact exists; it is complete only when the user gives an explicit approval for
that stage.

## Stage 0 — Script architecture review

When the script plan is ready, output only these review modules, in this order:

1. `Topic Theses`
2. `Hook Selection`
3. `H-C-E-R-M outline`

Stop with `awaiting_user_confirmation: stage_1_script_architecture`. Do not output the full
master script, Global visual DNA, image prompts, audiovisual beats, executable production
prompts, or Notion writes at this stage.

The approval must be explicit and scoped, for example `确认第1点` or `批准脚本结构`.
“继续” without a stage reference is not sufficient.

## Stage 1 — Visual test review

After Stage 0 approval, complete and freeze the upstream script semantics as needed, then
output exactly these review items:

1. `Global visual DNA`
2. Image prompt — `主角`
3. Image prompt — `场景`
4. Image prompt — `Key Frame`

The three prompts are the minimum LookDev test set. They are reviewable test prompts, not proof
of generated images, approved baselines, or permission to spend credits. Stop with
`awaiting_user_confirmation: stage_2_visual_test`.

The approval must be explicit and scoped, for example `确认第2点` or `批准视觉测试`.

## Stage 2 — Full production package and Notion projection

After Stage 1 approval, output the complete production materials: frozen script, audiovisual
direction package, production manifest, asset/clip/audio plans, executable prompts, gates, and
any unresolved risks. Only after that package is shown may the workflow write to Notion.

`确认第2点` authorizes the scoped Notion projection of this complete package into the existing
production structures. It does not authorize paid image, video, voice, SFX, or BGM generation;
those retain their independent cost and generation gates.

Notion projection requirements:

- reuse the existing `视频项目`, `制作资产`, and `Clips` structures;
- use an idempotency key and preserve a local pending record before the write;
- filter project-specific views by the exact project relation page ID;
- keep status, approval, QA, cost, and acceptance notes out of copy-ready prompt fields;
- read back the page body, relations, and formatting after the write;
- on permission, quota, or read-back failure, retain `DEGRADED`/retryable state and never claim
  the projection succeeded.

## State transition contract

```yaml
approval_state:
  stage: script_architecture | visual_test | full_production
  status: awaiting_user_confirmation | approved | blocked | complete
  approved_by: user | null
  confirmation_text: string | null
  notion_projection: not_authorized | authorized_after_stage_2 | written | degraded
```

Only the following transitions are valid:

```text
script_architecture/awaiting_user_confirmation
  --确认第1点--> visual_test/awaiting_user_confirmation
visual_test/awaiting_user_confirmation
  --确认第2点--> full_production/complete
```

An ambiguous, partial, or contradictory confirmation routes to human review and does not
advance the workflow.
