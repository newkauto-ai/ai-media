# Audio Production Review Projection

Render from `production_manifest.audio_production`; it is not a second source of truth.

```text
Audio status / provider / cost-gate state
Voice selection requirements: role, provenance, hard constraints, preferences, prohibited traits
Candidate shortlist (max 3 per role): display name, voice_type, score, matched evidence, provider route, source URL, account availability
Human decision: recommended candidate, selected voice (null until approved), unresolved evidence, provider-call authorization
Voice Profiles: ID, speaker, source provenance, provider voice selection, revision, status
Minimum requested set: audio ID, Beat/Scene/Clip, exact text, delivery controls, format, estimated duration, planned time, status
Assembly-ready assets: path, measured duration, checksum, QA evidence
Blocked or failed items: reason, owner, bounded next action
Deferred tracks: BGM / Foley / SFX
```

Never render access tokens, API keys, unverified claims of generated audio, account entitlement, or real-person voice identity assertions. A ranked candidate is not an approved Voice Profile.
