# Storyboard Contact Sheet Prompt

Use this template only for low-detail previsualization after Stage 1 approval and Scene/Clip planning. It is not a Production Asset, Visual Baseline, or paid-generation approval.

```text
Create one ordered storyboard contact sheet for previsualization only.

Project anchors:
{{CONSISTENCY_ANCHORS}}

Panels in reading order:
{{PANEL_BLOCKS}}

Requirements:
- keep every Panel ID visible and preserve the supplied reading order;
- express only the supplied composition, action, character position, environment, mood, continuity notes, and assigned story function;
- keep characters, clothing, props, spatial direction, and environment recognizable across panels;
- use simplified detail and low-production polish so composition and action remain easy to inspect;
- use only the declared non-realistic aids such as motion lines or simple emotion marks;
- do not invent plot, motives, characters, props, dialogue, transitions, or spectacle;
- do not turn this sheet into final key art, a Production Asset, or provider-specific prompt syntax;
- do not add subtitles, decorative text, watermarks, logos, or a finished poster layout.

Output specification:
{{OUTPUT_SPEC}}

Stopping condition:
Return one contact sheet only. Do not create variants or regenerate any panel unless a later Review names that Panel and a separate Cost Gate is approved.
```

For a Single Panel repair, preserve every non-target Panel by reference and include only the named `must_fix`, evidence, and repair target. A new real call still requires a separate Cost Gate.
