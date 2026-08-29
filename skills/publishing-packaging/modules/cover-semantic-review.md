# Cover Semantic Visual Review

Technical QA and semantic visual review are separate evidence sets. Technical PASS cannot promote semantic `fail`, `unknown`, or `human_review`.

```yaml
cover_semantic_review:
  review_version: "1.0"
  target_cover_hash: sha256
  evidence_source: human | evaluator
  required_subjects_present: pass | fail | unknown
  title_visual_match: pass | fail | unknown | human_review
  key_action_readable: pass | fail | unknown | human_review
  critical_subject_unoccluded: pass | fail | unknown
  thumbnail_readability: pass | fail | unknown | human_review
  identity_and_style_consistency: pass | fail | unknown | human_review
  platform_native_composition: pass | fail | unknown | human_review
  template_residue: pass | fail | unknown | human_review
  verdict: pass | fail | unknown | human_review
  findings: [object]
```

Missing required people, a title-picture mismatch, occluded faces/hands/cats, unreadable key action, mechanical crop, or visible template residue withholds `ASSET_READY`. Missing or hash-mismatched evidence stays `unknown`. These package-local results do not create Review Result v2.1 entries or consume Execution State retry authority.
