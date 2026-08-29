# Cover Prompt Request

Skill 5 resolves platform intent and sends a structured request to the existing Video Production image Prompt compiler.

Required order:

1. Resolve `story_hook`, platform-specific `platform_title`, and platform-specific `cover_title` independently.
2. Bind every approved character, scene, prop, style, action, and composition reference by path, version, approval, rights, role, and SHA-256.
3. Produce platform-native composition: Xiaohongshu 3:4 supports a relationship-led editorial frame and clean title space; Douyin 9:16 concentrates the action and avoids top/right/bottom UI.
4. Set `prompt_variant=cover_visual`, `asset_type=keyframe`, and `generate_text_in_image=false`.
5. Invoke the existing compiler and retain its `image_prompt_spec`, executable prompt, clause map, reference bindings, and call package.

No external image provider is called. The resulting call package is always `generation_status=not_authorized` until a separate cost/generation Gate is approved.
