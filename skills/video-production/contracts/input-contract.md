# Skill 4 Input Contract v1.7

```yaml
input:
  frozen_script: object
  audiovisual_direction_package: {contract_version: "1.2", semantic_locks: required, style_blueprint: required, audiovisual_beats: required, performance_plans: required, continuity_plan: required, production_handoff: required}
  approved_scene_coverage: [object]
  approved_scene_baselines: [object]
  evaluator_results: [object]
  selected_style_profiles: [{id: string, registry_status: ready}]
  semantic_template_bindings: object
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
- Preserve every ADP lock. Runtime design may add provenance but may not rewrite thesis, Hook, Reveal, factual claims, conclusion, or frozen identity/product facts.
- Output is planning and review data only. It must not claim a generated asset, human approval, actual continuity, or a final master.
- Enabling BGM Production requires ADP `music.music_brief` and a non-empty derived prompt. Provider connection approval alone cannot satisfy the separate generation Gate.
