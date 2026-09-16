# Audio Production Contract v1.1

Audio Production compiles locked Script text and ADP voice direction into provider-neutral voice requests, reusable Voice Profiles, and a timeline that can be assembled with Video Clips. V1 supports TTS voice only. It does not mix, create BGM/SFX/Foley, lip-sync, or imitate a real person.

## Required sources

```yaml
audio_production:
  enabled: boolean
  provider: doubao_tts | null
  output_format: mp3 | wav | ogg_opus
  asset_root: string | null
adp:
  character_voice_bible: [object]
  audiovisual_beats:
    - beat_id: string
      narration_or_dialogue: string | null
      audio: {voice_profile_id, dialogue, ambience, foley, sfx, silence}
      production: {complexity}
```

## Voice Profile

`voice_profile_id` is a reusable production record, not a provider credential or an asserted real-person identity.

```yaml
voice_profile:
  voice_profile_id: narrator-main
  scope: narration | character_dialogue
  speaker_id: NARRATOR | character asset ID
  speaker_name: string
  source_voice_direction: object
  provider_voice: {provider: doubao_tts, voice_type: string | null}
  delivery: {emotion, speech_rate, pause_style, emphasis}
  prohibited_traits: [string]
  provenance: source_locked | runtime_recommended
  status: draft | approved | retired
```

## Named-voice selection

Automatic selection is a recommendation step before Voice Profile approval. Requirements come from the frozen Character & Voice Bible and Script, with explicit provenance:

```yaml
voice_selection_requirement:
  voice_profile_id: string
  speaker_id: string
  speaker_name: string
  scope: narration | character_dialogue
  hard_constraints:
    language: string | null
    gender: male | female | null
    dialect: string | null
    provider_route: string | null
  preferences:
    age_band: child | teen | young_adult | adult | middle_aged | older_adult | null
    use_cases: [string]
    style_tags: [string]
  prohibited_traits: [string]
  provenance: source_locked | runtime_inferred
```

Hard constraints and prohibited traits filter candidates. Age, use case, and style only rank the survivors. Return at most three candidates per role, including `voice_type`, score, matched evidence, provider route, source URL, and `account_availability`. A public catalog entry does not prove that the current account can call it. Keep `selected_voice: null` and `provider_call_authorized: false` until account availability is verified and a human approves one candidate. No match is `blocked_no_candidate`; do not silently relax a hard constraint.

`doubao_big_model_tts_v3` is the fixed named-voice route. `seed_audio_v3_full_scene` accepts descriptive scene/voice prompting and must not be presented as a fixed `voice_type` selection route.

## Voice request and asset lifecycle

```text
planned → awaiting_user_approval → submitted → provider_complete → downloaded → qa_passed → ready_for_assembly
                                      └→ failed / stopped
```

Each `voice_request` must contain `audio_id`, `beat_id`, `scene_id`, exact `text`, `voice_profile_id`, provider, format, request controls, planned start/end, and the status above. `asset_path`, `provider_request_id`, checksum, measured duration, and QA evidence are empty until observed.

For any provider, retain the observed request/task identifier as `provider_request_id`. Temporary asset URLs are used only for immediate retrieval and are not retained in the Manifest; record expiry when available, downloaded byte length, and checksum instead.

## Timeline rules

- The Script text is immutable. Voice Prompt Generator may select documented delivery controls only; it cannot paraphrase, add pauses as spoken words, or change semantic locks.
- Estimated voice planning may use decimal seconds. Final assembly binds the confirmed audio file, checksum, measured duration, sample rate, and original absolute semantic intervals; it converts visual, caption, and SFX event boundaries to integer frames at the bound fps. One-decimal estimates are never final execution precision.
- Estimated duration uses the project baseline (Chinese: 4.2 effective speech units/sec adjusted by `speech_rate`, punctuation and 0.15s utterance buffer). Reconcile to the measured audio duration before assembly.
- A request that exceeds its owning Clip is a `timing_conflict`, not an automatic speed-up. Return it to audio timing review or split the locked Script upstream.
- Reuse requires the same text hash, approved Voice Profile revision, provider/voice type, rendering controls, output format, and checksum. Otherwise create a new asset revision.

For narration-led local assembly, `audio_production.final_narration_master` is one continuous read-only timing spine even when upstream voice generation used several requests. Do not require one WAV per Shot, automatically delete pauses, time-stretch audio, or move narration to fit a prebuilt visual timeline. Store `caption_output_owner: remotion | external_post` with exactly one final owner. Store SFX as separate asset/event refs: a whoosh binds a visible motion interval; an impact binds a visible settle or hit. A narration, Shot-order, or timeline revision makes affected SFX bindings stale and requires recheck. `bgm_output_owner: external_post` permits an intentional picture+narration+SFX intermediate without BGM and does not convert it into an accepted final master.

## Gate and security

- Never store API keys, access tokens, or secrets in the manifest, Voice Profile, template, logs, or Git.
- Named-voice recommendation does not authorize a provider call. Unknown account availability blocks generation but does not block producing a review shortlist.
- A live request requires explicit approval of provider, voice count, text set, output format, estimated cost, and stopping condition.
- The local fixture/compiler may create `planned` requests only. It cannot claim generated audio, quality, approval, or assembly readiness.
