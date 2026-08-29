# Audio Production Contract v1.0

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

## Voice request and asset lifecycle

```text
planned → awaiting_user_approval → submitted → provider_complete → downloaded → qa_passed → ready_for_assembly
                                      └→ failed / stopped
```

Each `voice_request` must contain `audio_id`, `beat_id`, `scene_id`, exact `text`, `voice_profile_id`, provider, format, request controls, planned start/end, and the status above. `asset_path`, `provider_request_id`, checksum, measured duration, and QA evidence are empty until observed.

For Doubao async TTS, retain the provider `task_id` as `provider_request_id`. The temporary `audio_url` is used only for the immediate download and is not retained in the Manifest; record its expiry time, retrieved sentence timing, downloaded byte length, and checksum instead.

## Timeline rules

- The Script text is immutable. Voice Prompt Generator may select documented delivery controls only; it cannot paraphrase, add pauses as spoken words, or change semantic locks.
- Plan to one decimal second. Video and voice run in parallel, so the Audio Timeline is not a single serial track.
- Estimated duration uses the project baseline (Chinese: 4.2 effective speech units/sec adjusted by `speech_rate`, punctuation and 0.15s utterance buffer). Reconcile to the measured audio duration before assembly.
- A request that exceeds its owning Clip is a `timing_conflict`, not an automatic speed-up. Return it to audio timing review or split the locked Script upstream.
- Reuse requires the same text hash, approved Voice Profile revision, provider/voice type, rendering controls, output format, and checksum. Otherwise create a new asset revision.

## Gate and security

- Never store API keys, access tokens, or secrets in the manifest, Voice Profile, template, logs, or Git.
- A live request requires explicit approval of provider, voice count, text set, output format, estimated cost, and stopping condition.
- The local fixture/compiler may create `planned` requests only. It cannot claim generated audio, quality, approval, or assembly readiness.
