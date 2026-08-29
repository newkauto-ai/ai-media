# Notion Projection Dry Run

Read a local Publish Package, the read-only live schema snapshot, the target project relation, and a read-only row snapshot. Emit `notion-projection.json` plus a Markdown Preview without calling Notion.

The projector applies the stable projection key, allowlisted properties, exact minimal schema delta, CREATE/NO_CHANGE/UPDATE/CONFLICT/DEGRADED rules, unique Snapshot heading rule, and degraded local-binary attachment policy from the Notion Projection Contract.

It must preserve local Package authority and emit an external-action audit with `notion_write=0`, `publish=0`, `remote_draft=0`, `paid_generation=0`, `upload=0`, and `browser_automation=0`.
