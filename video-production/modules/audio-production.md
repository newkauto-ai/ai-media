# Audio Production Module

Turn the frozen Script and ADP voice direction into portable, inspectable voice assets. This module owns runtime voice selection, request planning, timing reconciliation, and audio asset metadata; it does not rewrite the Script or director intent.

## Procedure

1. Read the Audio Production Contract and confirm `audio_production.enabled`. If false, write `disabled` and do nothing else.
2. Extract every non-empty `narration_or_dialogue`. Use `audio.voice_profile_id` to resolve role requirements from ADP voice identity/Character & Voice Bible. Source-defined values are authoritative; label any runtime interpretation as provisional. Missing mapping is a blocker.
3. When a named Doubao voice is not already approved, run `scripts/select-doubao-voices.ps1`. Apply language, gender, dialect, provider route, and prohibited-trait filters first; then score age, use case, and style. Return at most three candidates per role. Do not relax a hard constraint when no candidate remains.
4. Present candidate evidence and unresolved account availability. Recommendation is not final selection: keep `selected_voice` empty and do not create provider calls until a human approves one account-available voice. Keep Seed Audio v3 full-scene prompting separate from fixed `voice_type` selection.
5. Build the approved Voice Profile and Voice Prompt record: exact text plus profile, emotion baseline/beat state, speech rate, pause style, emphasis, and source provenance. It is structured delivery metadata, not freeform text injected into the spoken line.
6. Generate a deterministic `audio_id` (`A-<beat_id>-V<n>`), compute text/profile revision hashes, estimate duration, and place it against its owning Scene/Clip. Flag overflow as `timing_conflict`.
7. Present the minimum voice set, provider, count, format, estimated cost, output root, and stopping condition for explicit approval.
8. After approval, call the selected adapter. Save original response metadata, generated file, duration, checksum, QA result, and revision. Do not overwrite an approved prior revision.
9. Reconcile the Audio Timeline with measured durations and release only `qa_passed` assets to Assembly. For narration-led local assembly, bind the confirmed continuous result as read-only `final_narration_master` with checksum, measured duration, sample rate, and absolute semantic intervals. Preserve original timing and pauses; convert visual/caption/SFX boundaries to integer frames only after fps is bound. Record exactly one `caption_output_owner`, bind whoosh to visible motion intervals and impact to visible settle/hit events, and mark affected bindings stale after any narration or timeline revision. External-post BGM ownership may intentionally leave the Remotion intermediate without BGM.

## V1 audio QA

- Complete, intelligible output; no truncation/corruption.
- Exact Script text (manual or ASR-assisted verification), approved speaker/profile, and delivery broadly match direction.
- Measured duration fits timing policy or has an explicit editing decision.
- File format, path, checksum, provider request ID, and rights/approval record are present.

Failure taxonomy: `missing_voice_profile`, `provider_not_configured`, `cost_gate_missing`, `provider_rejected`, `render_failure`, `text_mismatch`, `delivery_mismatch`, `timing_conflict`, `audio_corruption`, `rights_or_consent_missing`.
