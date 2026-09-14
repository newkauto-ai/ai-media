# Skill 4 Input Contract v1.7

```yaml
input:
  workflow_mode: managed_production | external_prompt_only
  prompt_fast_path_input: {strategy: S1 | S2 | S3 | S4 | null, topic_or_goal: string | null, target_duration_seconds: number | null, aspect_ratio: string | null, content_type: string | null, references_available: [image | video | audio], named_style_request: [string], named_style_scope: personal_study | null, must_hold: [string], audio_intent: native_audio | narration_later | silent | unknown}
  frozen_script: object
  audiovisual_direction_package: {contract_version: "1.2", semantic_locks: required, style_blueprint: required, audiovisual_beats: required, performance_plans: required, continuity_plan: required, production_handoff: required}
  approved_scene_coverage: [object]
  approved_scene_baselines: [object]
  evaluator_results: [object]
  selected_style_profiles: [{id: string, registry_status: ready}]
  semantic_template_bindings: object
  video_adapter: {platform: string | null, access_route: string | null, model_id: string | null, model_version: string | null, target_resolution: string | null, aspect_ratios: [string], duration_options_seconds: [number], reference_modes: [string], native_audio_strategy: native_speech | silent | unknown, evidence_refs: [string]} # optional compatibility record; not a stage or Gate
  delivery_spec: {aspect_ratio: string | null, image_resolution: string | null, video_resolution: string | null, native_audio_mode: separate_tracks | native_speech | silent}
  image_assets:
    - asset_id: string
      asset_type: character_identity | scene | prop | graphic | keyframe
      prompt_variant: default | story_prop | product_evidence | cover_visual
      image_prompt_spec: object
      output_spec: {aspect_ratio, size, quality, background, output_format}
  audio_production: {enabled: boolean, provider: doubao_tts | null, output_format: mp3 | wav | ogg_opus, asset_root: string | null}
  bgm_production: {enabled: boolean, provider: elevenlabs_music | null, model_id: music_v2 | null, output_format: mp3_48000_192, asset_root: string | null}
  cover_prompt_requests: [object] # optional Skill 5 handoff; local compilation only
```

- Accept ADP v1.2 as the current input. ADP v1.1 remains a read-only compatibility input for the local fixture compiler; it cannot claim a v1.2 performance plan without an explicit migration record.
- Reject any current input missing frozen semantic locks, Visual DNA, Beats, or LookDev specification. Scene coverage and baselines may be empty when no trigger is derived, but a triggered Scene must bind approved coverage.
- Image assets must declare type and variant. `product_evidence` requires inspected source locks; do not infer product features from a model, cache, or uninspected image.
- `cover_visual` requests must use the existing image Prompt compiler, bind approved visual references, reserve clean post-layout title space, and set exact-text generation false. They do not require final video and never authorize real generation.
- `delivery_spec` may be unresolved during planning, but any corresponding image or Clip remains blocked before generation. Image output values may be Adapter parameters but must appear in a reviewable call package.
- Do not request or create a `video_adapter` record at project start. If an existing compatibility record or observed UI facts are available, they may be reused as evidence, but they never form a stage or Gate. Confirm only materially required execution parameters in the generation request's Cost Gate or call package immediately before submission; planning must not silently substitute official model capabilities for the actual execution surface.
- `external_prompt_only` is additive and does not require `frozen_script`, an ADP, approved Style Profiles, a Manifest, LookDev, Storyboard, Notion, or a Cost Gate. It may compile directly only when the supplied S1/S2 content already states a clear goal, visible change or ending, and no more than three `must_hold` items; otherwise route missing content to its existing owner. Its versioned Prompt Package is the one semantic-acceptance binding for any later external review; Must Hold, state target, and reference responsibilities are derived from that package rather than duplicated snapshots. Unresolved duration, aspect ratio, or execution-surface parameters remain `UNKNOWN` in the package rather than being guessed.
- A named Viral Feed selection uses the existing `selected_style_profiles` field and must resolve to exactly one ready registry Profile. Its current supported exact names are `迷你厨房烹饪`, `纸板制作任意物品`, and `美女跳舞卡点变装`; each maps only to its documented stable ID in `audiovisual-director/router/style-ingestion.md`. Do not infer a near match, combine types, or let the selected Profile override Adapter model, version, resolution, duration, aspect ratio, or provider behavior.
- Preserve every ADP lock. Runtime design may add provenance but may not rewrite thesis, Hook, Reveal, factual claims, conclusion, or frozen identity/product facts.
- Output is planning and review data only. It must not claim a generated asset, human approval, actual continuity, or a final master.
- Enabling BGM Production requires ADP `music.music_brief` and a non-empty derived prompt. Provider connection approval alone cannot satisfy the separate generation Gate.
