# Script Review and Frozen Package

## Stage 0 review gate

For the first response of an end-to-end run, output only the following three modules and then
stop for explicit user confirmation:

1. `Topic Theses`
2. `Hook Selection`
3. `H-C-E-R-M outline`

Confirmation request: `请确认第1点（确认脚本结构）后，我再输出 Global visual DNA 和三张资产图片提示词。`

Do not include the full master script, visual DNA, asset prompts, audiovisual beats, executable
production prompts, or Notion write results before this gate is approved.

For a structure-locked `reference_video_structural_remake`, keep the same confirmation boundary but
replace `Hook Selection`/`H-C-E-R-M outline` with the already selected Hook (when present) and a
`Reference structure and target adaptation mapping`. Preserve source order and mark non-applicable
dramatic fields explicitly; do not manufacture them to fill this template.

## Topic Thesis

- Topic:
- Core thesis:
- Primary user driver:
- Concrete scenario:
- State change: A → B
- Propagation motive:
- Unique supply:
- Target duration from Topic Hunter (seconds):
- Duration rationale / current user constraints:

## Hook selection

List at least five candidates, select one, and explain the choice briefly.

## H-C-E-R-M outline

- Hook:
- Conflict:
- Escalation:
- Reveal:
- Meaning:

## Complete master script Draft at the approved topic duration

- Script ID / version:
- Draft status: `draft` (do not mark `frozen` before Review READY)
- Approved Topic Hunter target duration:
- Estimated duration / fit and any unresolved variance:
- Full text:
- Semantic locks: core thesis, Hook, Reveal, core conclusion, factual claims.

## Retention and compression audit

- Three compression passes:
- 5-second death test:
- New-stimulus intervals:
- Sentence-function exceptions:

## Script Quality Review (between Draft and Freeze)

```yaml
script_quality_review:
  mode: lite | full
  decision: READY | REVISE
  revision_scope: none | local | structural
  must_fix:
    - failure_type:
      evidence:
      repair_target:
      owner: script_engine | human_decision
  optional:
    - note:
  do_not_optimize:
    - preserved_strength:
  stop_reason:
```

The Reviewer only reports evidence-backed findings and repair targets. It does not rewrite the Script. Include at most three Must Fix findings. Optional-only results are READY and must say `STOP SCRIPT OPTIMIZATION`. A local repair may run once through the existing `script_quality` retry budget; structural change or a failed recheck stops for human review.

## Frozen master script at the approved topic duration

Complete this projection only after the Script Quality Review returns READY.

- Script ID / version:
- Frozen status: `frozen`
- Approved Topic Hunter target duration:
- Estimated duration / fit and any unresolved variance:
- Full text:
- Semantic locks: core thesis, Hook, Reveal, core conclusion, factual claims.

## Production Handoff Manifest

- Major character count:
- Core scene count:
- Visual beat count estimate:
- Consistency risks:
- Reusable assets:
- Production complexity:
- Over-budget treatment:

## Story Change Arc (only for a genuine pivotal choice or emotional turn)

- Arc ID / character:
- Pivotal change: true / false
- Trigger event:
- Initial internal state:
- Conflict or deliberation:
- Choice or change:
- Resulting action:
- End internal state:
- Semantic locks:
- Authority: `script_engine`

The downstream package may reference this arc but may not rewrite its motivation, choice, resulting action, or semantic locks.

## Low-cost platform packaging

Legacy/provisional handoff only. Use the same master video for Douyin and Xiaohongshu. Adapt title, caption, tags, and an existing-frame cover hint, and identify the strongest 30–60 second segment for YouTube Shorts. Publishing & Packaging v1.1 is the final authority for platform copy, actual cover files, publish windows, compliance projection, and Package readiness.
