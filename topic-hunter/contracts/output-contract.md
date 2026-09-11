# Topic Hunter Output Contract v1.1

The machine-readable output must follow this shape. Human-readable labels may be Chinese, but field meanings must not change.

```yaml
topic_hunter_output:
  contract_version: "1.1"
  candidate_count: integer # 20-30 before screening
  screening_summary:
    rejected_count: integer
    deep_screened_count: integer
    rejection_reasons: [string]
  recommendations:
    - rank: 1 | 2 | 3
      topic_id: string
      topic: string
      target_duration_seconds: integer # positive total video target, chosen by Topic Hunter
      duration_rationale: string # why this topic needs this duration; identify user constraints if present
      topic_thesis:
        topic: string
        core_thesis: string
        user_desire_or_need:
          primary: string
          secondary: string | null
        concrete_scenario: string
        intended_state_change:
          type: cognition | viewpoint | emotion | behavior | identity
          from: string
          to: string
        propagation_motive:
          primary_action: share | comment | save
          reason: string
        unique_supply: string
      gate_1:
        clear_dimensions: integer # 4-5 for final Top 3
        result: pass
      content_potential_score:
        conflict: integer # 0-2
        curiosity: integer # 0-2
        reversal: integer # 0-2
        resonance: integer # 0-2
        extension: integer # 0-2
        total: integer # exact sum, 0-10
      click_trigger: high | medium | low
      ai_production_difficulty: high | medium | low
      long_form_extension: string
      core_conflict: string
      recommendation: string
  selected_topic_id: string # must equal rank 1 topic_id
  selection_reason: string
```

## Skill 1 to Skill 2 mapping

Script Engine must receive the selected recommendation's complete `topic_thesis`, `target_duration_seconds`, and `duration_rationale`, not only its title. Topic Hunter owns the duration recommendation; it is reviewed with the existing Stage 0 package, not a new approval Gate. For an already selected or imported Topic Thesis lacking this plan, perform only a bounded duration recommendation on that topic; do not regenerate the shortlist or replace its thesis. Reconcile a requested duration change with the current user instruction through this owner and return the updated plan.

| Business label | Canonical field |
|---|---|
| 一句话 Content Thesis | `topic_thesis.core_thesis` |
| 用户驱动力 | `topic_thesis.user_desire_or_need` |
| 具体场景 | `topic_thesis.concrete_scenario` |
| 状态变化 | `topic_thesis.intended_state_change` |
| 传播动机 | `topic_thesis.propagation_motive` |
| 独特供给 | `topic_thesis.unique_supply` |

The Topic Thesis formula is a construction and review framework, not a numeric multiplication formula.
