# Seed Audio 1.0 V3 Provider Adapter v1.0

This adapter is the active Volcengine full-scene audio path. It is separate from the removed legacy App ID/Access Token async TTS adapter and does not silently claim to use the Voice_Type registry.

## Configuration

Use the Windows user/process environment variable below. Never put its value in a script, manifest, runtime record, log, or source-controlled file.

```text
VOLCENGINE_TTS_V3_API_KEY    required
```

The guarded entry point is `scripts/invoke-seed-audio-v3.ps1`. It is dry-run by default and requires `-Execute`. It writes only a decoded audio file and non-secret local verification metadata; it does not persist the temporary provider URL or inline Base64 response.

## Request

The V3 endpoint is:

```text
POST https://openspeech.bytedance.com/api/v3/tts/create
X-Api-Key: <environment value>
Content-Type: application/json
```

The request uses `model=seed-audio-1.0`, `text_prompt`, `audio_config`, and `watermark`. The prompt may describe dialogue, ambience, music, and SFX as one full scene.

## Response and QA boundary

The observed success response is JSON containing inline Base64 `audio`, `duration`, `original_duration`, and a temporary `url`. The adapter decodes `audio` to the approved output path and records byte length and SHA-256. `ffprobe`/`ffmpeg` checks establish file/container integrity only; human listening, ASR text verification, voice quality, and editorial approval remain separate QA steps.

V3 scene generation is not a replacement for a narrator-only Voice_Type request. If production needs a reusable preset voice, add and verify that mapping explicitly in the Voice_Type database before using it.
