# Completion Report — Workflow Controller v1.0

## Result

**PASS for bounded local orchestration and Fixture validation.** The project now has a project-level `workflow-controller` Skill that turns a structured evaluation into one auditable next action across Topic, Script, Direction, and Production. It adds conditional capability routing, optional-step skipping, bounded retries, and mandatory human escalation.

## Files Created

- `workflow-controller/SKILL.md`
- `workflow-controller/contracts/execution-state.md`
- `workflow-controller/contracts/evaluator-result.md`
- `workflow-controller/policies/route-policy.md`
- `workflow-controller/scripts/decide-next-action.ps1`
- `tests/fixtures/workflow-controller-scenarios.json`
- `tests/verify-workflow-controller.ps1`

## Implemented behavior

- A unit records stage, required/optional status, topic type, production risk, retry count, retry budget, and state.
- An evaluator result must identify its source, verdict, confidence, observable evidence, named failures, semantic impact, and external-evidence requirement.
- Historical, science, and health work with unresolved claims routes to `research` rather than freezing a Script.
- A named Script quality failure can rerun only `script-engine`; a production Domain failure can rerun only the affected `video-production` unit.
- A low-risk optional Storyboard can skip to Keyframe planning. Required Gates cannot skip.
- Semantic impact, low confidence, unsupported route, or exhausted retry budget routes to human review. Default retry budget is two attempts per unit.

## Verification

Observed on 2026-08-23:

```powershell
& '.\tests\verify-workflow-controller.ps1'
```

The six scenarios passed: Script retry, evidence route, optional low-risk Storyboard skip, targeted production retry, semantic-change escalation, and retry-budget escalation. The final combined regression also passed all Skill 1–4 tests plus this controller test. The bundled UTF-8 Python runtime returned `Skill is valid!` for `workflow-controller`.

## First live Script-quality loop

On 2026-08-23, the current Codex LLM assessed frozen `script-xyj-001` and recorded the result in `workflow-controller/runs/2026-08-23-script-xyj-001-evaluation-01.json`. Structure and retention passed, but its two factual claims lacked primary-text references, so the controller produced `blocked → research` in `decision-01.json`.

The research action produced `research/西游记_脚本事实核验_2026-08-23.md`. It verifies the party formulation in Chapters 8, 54, and 100, and three independent artifact-owner episodes in Chapters 35, 52, and 66. The second LLM assessment recorded that evidence boundary without changing the frozen Script. The controller then produced `complete → audiovisual-director` in `decision-02.json`.

## Boundary Check

- No image, video, audio, or publishing tool was invoked.
- The real current-session LLM and a primary-text research action completed one Script-quality loop; the six Fixture assessments still prove only policy transitions.
- No frozen Topic Thesis, Script, or ADP semantic lock can be auto-rewritten by the controller.
- No controller outcome bypasses existing LookDev or user cost approval Gates.

## Next Action

One Script-quality loop is complete. Before connecting the controller to media generation, validate a second run with a genuine named quality failure and inspect whether the bounded retry actually improves the Script; paid-generation approval remains separate.
