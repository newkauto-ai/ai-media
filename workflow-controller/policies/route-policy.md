# Route Policy v1.2

| Condition | Permitted next action |
|---|---|
| A cost-incurring generation request lacks a materially required execution parameter | request only the missing parameter at the existing Cost Gate or call package; do not create a Video Adapter intake, stage, or artifact |
| `workflow_mode=external_prompt_only` and strategy is absent | recommend S1–S4 plus at most one meaningful alternative; request one strategy choice and stop |
| `workflow_mode=external_prompt_only`, strategy selected, and explicit S1/S2 content is sufficient | route one `video-production` Fast Path compilation; do not request Script Architecture, LookDev, Storyboard, Manifest, Notion, or a Cost Gate |
| `workflow_mode=external_prompt_only` has missing topic, script/dialogue/fact, or compact-direction content | route only the missing work to `topic-hunter`, `script-engine`, or `audiovisual-director`; return to Controller after its envelope |
| `workflow_mode=external_prompt_only` pre-generation prompt check passes | stop at `prompt_ready_for_external_use`; no provider call, Cost Gate, or media-QA claim |
| User reports media with uniquely confirmed `external_prompt_only` Prompt Package, input hash, actual request parameters, and reference roles | re-read final media checksum and technical specification, then route one Manifest-free `external_result_review`; return one recommendation and stop |
| User reports media with no or contradictory Fast Path attribution | route technical checks only; request the exact Prompt Package/request/reference binding or human decision; do not route Manifest intake or semantic QA |
| Topic selection passes | `script-engine` |
| Script plan is ready | stop at `stage_1_script_architecture` and request explicit user confirmation |
| Stage 0 confirmation is explicit and valid | route one `audiovisual-director` action; re-observe its return before selecting LookDev |
| Historical, science, or health topic requires unresolved evidence | block and route `research`; do not freeze a script |
| Script-quality retry with a named, non-semantic failure and remaining budget | retry `script-engine` |
| Stage 1 visual test package is ready | stop at `stage_2_visual_test` and request explicit user confirmation |
| Stage 1 confirmation is explicit and valid | route one `video-production` action to compile the full production package; any Notion projection remains a separately selected action |
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
| Full workflow, resume, status, or next-step intent with project context | run one bounded reconciliation, then select one existing action |
| User reports generated or edited media not uniquely bound in Manifest | route one `video-production` media-intake action; stop and return Controller |
| Reported media has a unique Manifest target, revision, and checksum and awaits Review | route one `video-production` `production_qa` action |
| User accepts or rejects media without exact target or checksum | `human_review`; request exact target binding |
| Specialist returns a project artifact or formal Review | re-observe artifact and approval state before any advancement |
| Claimed artifact is missing, unreadable, or has unknown schema/hash/version | block for evidence; do not consume retry budget |
| Target or dependency hash changed | mark prior Review stale through existing lineage rules; do not consume retry budget |
| Current Stage waits for explicit approval | stop and request the exact Stage confirmation; generic “continue” is insufficient |
| User asks to propagate beyond the validated sample | check risk coverage, Clip-first scope, and Cost Gate; do not batch automatically |
| Whiteboard 1.3 Pilot fingerprint is new or lacks exact human acceptance evidence | route one risk-selected representative Pilot only; block propagation and formal segmented rendering |
| Whiteboard 1.3 Pilot fingerprint exactly matches recorded human acceptance and the benchmark-backed render plan is current | route one `video-production` single or next serial segment action; re-observe before continuing |
| Whiteboard segment technical check fails | retain passed segments, stop downstream, and route the named failed unit through existing Execution State; do not create another retry owner |
| Whiteboard Pilot or merged final is only technically successful | keep `success_pending_human_review`; request continuous human viewing before acceptance |
| Bounded specialist-only question has no stage, lineage, approval, or external-action mutation | route directly to the owning Specialist; Controller optional |

This policy chooses capabilities, not hidden implementation tools. Each decision selects one owning capability and one atomic next action, then stops before another Skill, Gate, unit, or external action. The selected Skill still validates its own input and must obey all cost and approval Gates. `external_prompt_only` is the documented exception: its only Gate is strategy selection, and its PASS is a manual-use prompt package rather than generation authority. Its later External Result Review is Manifest-free and never changes managed retry, Gate, actual-state, or selected-media owners. Stage 2 approval authorizes only the scoped Notion projection; it never grants paid media generation approval.
