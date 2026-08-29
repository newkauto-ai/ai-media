# Scene and Clip Planner

Create a Scene when location, time, world state, character set, costume/state, or lighting logic materially changes. Pack adjacent ADP Beats into a Clip only when character, action, emotion, and space are continuous and the Adapter supports the total duration.

Clip is the generation unit. It may contain one or more Shots. A Shot is a real cut; a Camera Beat is a movement phase inside a Shot. Record all four identifiers separately. Use 6–14 seconds for an initial Clip unless a configured Adapter supports a different stable range. If a complex multi-shot plan fails, split it into two continuous Clips with a Resume Keyframe rather than many independent short Shots.

For each Scene, emit structured `coverage_id`, `axis_group_id`, `view_direction`, `shot_size`, `visible_zone_ids`, and `reveals_new_space` inputs. The last field is an approved structured/semantic/human assessment, not a keyword result. Same-axis shot-size changes may reuse the same coverage; a new Scene Setting requirement is derived only when a reused Scene has at least two materially different reviewed coverage entries.
