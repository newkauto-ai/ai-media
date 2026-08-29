# Audio Production Module

Turn the frozen Script and ADP voice direction into portable, inspectable voice assets. This module owns runtime voice selection, request planning, timing reconciliation, and audio asset metadata; it does not rewrite the Script or director intent.

## Procedure

1. Read the Audio Production Contract and confirm `audio_production.enabled`. If false, write `disabled` and do nothing else.
2. Extract every non-empty `narration_or_dialogue`. Use `audio.voice_profile_id` to resolve a Voice Profile from ADP voice identity/Character & Voice Bible. Missing mapping is a blocker.
3. Build a Voice Prompt record: exact text plus profile, emotion baseline/beat state, speech rate, pause style, emphasis, and source provenance. It is structured delivery metadata, not freeform text injected into the spoken line.
4. Generate a deterministic `audio_id` (`A-<beat_id>-V<n>`), compute text/profile revision hashes, estimate duration, and place it against its owning Scene/Clip. Flag overflow as `timing_conflict`.
5. Present the minimum voice set, provider, count, format, estimated cost, output root, and stopping condition for explicit approval.
6. After approval, call the selected adapter. Save original response metadata, generated file, duration, checksum, QA result, and revision. Do not overwrite an approved prior revision.
7. Reconcile the Audio Timeline with measured durations and release only `qa_passed` assets to Assembly.

## V1 audio QA

- Complete, intelligible output; no truncation/corruption.
- Exact Script text (manual or ASR-assisted verification), approved speaker/profile, and delivery broadly match direction.
- Measured duration fits timing policy or has an explicit editing decision.
- File format, path, checksum, provider request ID, and rights/approval record are present.

Failure taxonomy: `missing_voice_profile`, `provider_not_configured`, `cost_gate_missing`, `provider_rejected`, `render_failure`, `text_mismatch`, `delivery_mismatch`, `timing_conflict`, `audio_corruption`, `rights_or_consent_missing`.
