# LookDev Test Spec Contract v1.1

Use the ADP `production_handoff.lookdev_test_spec` without widening it. It must select 3–5 representative anchors and require all five dimensions: `global_style`, `domain_identity`, `world_scale`, `story_usability`, and `reference_usability`.

Each anchor records `anchor_id`, type, subject, optional `domain_id`, executable prompt, generation result reference, AI QA result, human approval state, and baseline binding. The baseline binding is valid only when it contains all three: ready Style Profile, approved executable prompt, and approved generated image.

First appearance of a Style, character direction, or Domain requires AI QA and human approval. A failed Domain records `domain_blocked`; it does not revoke unrelated approved Domains. No local preview, fixture, or model judgment can replace a human approval record.
