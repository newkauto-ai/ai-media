# ElevenLabs Music v2 Provider Adapter v1.0

Use this adapter for one independent instrumental BGM asset after the BGM Production Contract passes and the user approves the exact cost Gate.

## Configuration

Use the Windows user/process environment variable below. Never put its value in a script, Manifest, Gate, runtime record, log, or source-controlled file.

```text
ELEVENLABS_API_KEY    required for a live request
```

The guarded entry point is `scripts/invoke-elevenlabs-music-v2.ps1`. It is dry-run by default. A live request requires `-Execute`, approval evidence, an exact approved prompt hash, and an approved credit ceiling.

## Request

```text
POST https://api.elevenlabs.io/v1/music?output_format=mp3_48000_192
xi-api-key: <environment value>
Content-Type: application/json
```

```json
{
  "prompt": "approved prompt",
  "music_length_ms": 60000,
  "model_id": "music_v2",
  "force_instrumental": true,
  "sign_with_c2pa": false
}
```

`music_length_ms` must be 3000–600000. This adapter does not send `seed` with a prompt, does not use a composition plan in v1, and does not request provider-side storage for inpainting.

## Response and QA boundary

The compose endpoint returns audio bytes and may return a `song-id` response header. The request helper writes the approved audio path plus a non-secret provider metadata JSON file. The wrapper then records byte length, SHA-256, request parameters, prompt hash, and estimated credits. It never persists the API key.

Provider success is not BGM approval. Measure and decode the file, then perform human listening and timeline decisions for trimming, fades, ducking, silence, and precise cue placement.
