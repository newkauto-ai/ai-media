# BGM Production Contract v1.0

BGM Production converts the approved ADP Music Brief and derived music prompt into one independent, reviewable music asset request. It never embeds music in a Video Clip Prompt and never treats a provider response as editorial approval.

## Required sources

```yaml
bgm_production:
  enabled: boolean
  provider: elevenlabs_music | null
  model_id: music_v2 | null
  output_format: mp3_48000_192
  asset_root: string | null
adp:
  music:
    music_brief: object
    suno_prompt: string
```

The field name `suno_prompt` is retained for ADP v1.1 compatibility. At runtime it is a provider-neutral semantic music prompt; the selected BGM Adapter may normalize transport parameters but may not change its narrative function, emotional arc, instrumentation, prohibitions, or instrumental requirement.

## Request and asset lifecycle

```text
planned → awaiting_user_approval → submitted → provider_complete → downloaded → qa_passed → ready_for_assembly
                                      └→ failed / stopped
```

```yaml
bgm_request:
  bgm_id: string
  provider: elevenlabs_music
  model_id: music_v2
  prompt: string
  prompt_sha256: string
  music_length_ms: 3000..600000
  force_instrumental: true
  output_format: mp3_48000_192
  estimated_credits: number
  provider_song_id: string | null
  asset_path: string | null
  checksum_sha256: string | null
  measured_duration_seconds: number | null
  qa: object | null
  status: string
```

The first implementation generates instrumental BGM only. Do not send a named artist, band, song title, copyrighted lyrics, or a request to imitate an existing work. Exact musical hits, drops, ducking points, and silence points are editorial targets; generation does not prove frame-accurate compliance.

## Gate, security, and stopping condition

- Never store an API key in a prompt, Manifest, Gate, runtime record, source file, or log. Read `ELEVENLABS_API_KEY` only at the guarded provider boundary.
- A live request requires exact approval of provider, model, prompt hash, duration, quantity, output format, estimated credits, monetary-cost status, output path, and stopping condition.
- Current planning uses ElevenLabs' published approximate rate of 900 credits per generated minute. Record the estimate date and keep monetary cost `unknown_plan_dependent` until the user's subscription is known.
- The guarded script is dry-run by default. `-Execute` also requires matching approval evidence, approved prompt SHA-256, and an approved credit ceiling.
- One approval authorizes one request only. Stop after the file and non-secret provider metadata are downloaded; do not retry, extend, inpaint, regenerate, mix, or assemble without a new decision.

## QA boundary

File existence, nonzero bytes, container decode, duration, and checksum establish technical integrity only. Human listening must separately assess narrative fit, instrumentation, unwanted vocals, musical arc, editability, clipping, artifacts, and whether silence/ducking should be created in the timeline rather than regenerated.
