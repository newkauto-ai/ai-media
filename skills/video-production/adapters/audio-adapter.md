# Audio Adapter

Voice, Foley, transient SFX, and BGM are separate assets. Select runtime capabilities and costs only at an approved production Gate. Preserve locked Script text, ADP sound cues, and voice direction; do not embed BGM into video generation instructions.

Voice Production v1 implements TTS voice requests. Voice requests are provider-neutral and include text, `voice_profile_id`, delivery controls, requested format, deterministic asset ID, planned placement, and provenance. BGM Production v1 is a separate contract with an ElevenLabs Music v2 provider path. Foley and SFX remain independently planned/deferred; no asset type is silently replaced with another.

No voice provider is configured merely by adding this document. A provider call requires: enabled audio production, a selected provider voice, required environment variables, an explicit cost Gate, and an output path under the approved asset root.
