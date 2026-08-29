# Scene Continuity Gate

The Scene Setting Gate is a deterministic projection of reviewed coverage. It does not inspect free text and does not treat a Key Frame or Resume Frame as a Scene Setting asset.

For a Scene, derive `reuse_count` from `clip_ids` and derive `multi_clip_multi_angle` from coverage relations. Set `scene_setting_requirement=required` only when at least two Clips use the Scene and the reviewed coverage contains different `axis_group_id` values or `reveals_new_space=true` with a different visible-zone set. Same-axis close/medium changes remain `not_required`.

```yaml
scene_setting_gate:
  status: not_required | planned_awaiting_cost_approval | approved_baseline_ready | blocked | unknown
  validator_type: deterministic | semantic | human | mixed
  evidence: [string]
  confidence: high | medium | low
  owner: video_production | human_decision
  failures: [scene_coverage_binding_missing]
  repair_targets: [string]
```

An `approved_baseline_ready` result requires a baseline binding for every required coverage ID. A local Fixture may leave generated references, AI QA, and human approval null; it must then remain planned/blocked and never become a real generation claim.
