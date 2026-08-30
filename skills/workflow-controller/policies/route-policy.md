# Route Policy v1.1

| Condition | Permitted next action |
|---|---|
| Topic selection passes | `script-engine` |
| Script plan is ready | stop at `stage_1_script_architecture` and request explicit user confirmation |
| Stage 0 confirmation is explicit and valid | `audiovisual-director` then `video-production` LookDev test package |
| Historical, science, or health topic requires unresolved evidence | block and route `research`; do not freeze a script |
| Script-quality retry with a named, non-semantic failure and remaining budget | retry `script-engine` |
| Stage 1 visual test package is ready | stop at `stage_2_visual_test` and request explicit user confirmation |
| Stage 1 confirmation is explicit and valid | compile full production package, then project to Notion |
| Direction pass without Stage 0 approval | block; do not emit visual DNA or image prompts |
| Production package without Stage 1 approval | block; do not write Notion |
| Script-quality pass | `audiovisual-director` |
| Direction pass | `video-production` |
| Low-risk storyboard assessed as optional | skip Storyboard and advance to Keyframe planning |
| Medium/high-risk Storyboard | retain Storyboard/Keyframe planning |
| Storyboard Review PASS with current non-fixture media evidence | complete Storyboard and advance to Prompt planning; do not request a Cost Gate |
| Storyboard Review fixture, missing media identity, or stale target/dependency hash | block for current evidence; do not consume retry budget |
| Storyboard Review named non-semantic Must Fix with budget remaining | repair only the named Panel through `video-production` |
| Production `domain_identity_failure` with budget remaining | retry affected unit through `video-production` only |
| Production QA core function satisfied with only Optional / Do Not Optimize findings | accept current material and stop optimizing |
| Production QA defect is locally editable/reusable | edit or reuse only the failed unit through `video-production` |
| Production QA evidence-backed Must Fix is not editable and improvement is medium/high | request the separate regeneration Cost Gate; do not call a provider |
| Production QA missing media identity, low expected improvement, semantic impact, unclear owner, or exhausted budget | `human_review` |
| Pre-generation prompt Review PASS from non-fixture evidence | request the separate Cost Gate; do not call a provider |
| Pre-generation Review UNKNOWN or stale hash | block for review evidence; do not consume retry budget |
| Pre-generation WARNING/FAIL with one named non-semantic repair and budget remaining | retry only the owning Video Production unit |
| Any semantic impact, low confidence, unknown capability, contradictory evidence, or exhausted budget | `human_review` |

This policy chooses capabilities, not hidden implementation tools. The selected Skill still validates its own input and must obey all cost and approval Gates. Stage 2 approval authorizes only the scoped Notion projection; it never grants paid media generation approval.
