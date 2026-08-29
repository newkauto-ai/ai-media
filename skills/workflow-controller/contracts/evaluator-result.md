# Evaluator Result Contract v1.1

An LLM evaluator must return structured output rather than prose-only self-critique:

```yaml
assessment:
  source: llm | deterministic_check | human | fixture
  run_id: string | null
  verdict: pass | retry | skip | blocked | human_review
  confidence: high | medium | low
  evidence: [string] # artifact fields, test names, or observed result references
  failure_types: [string]
  affects_semantics: boolean
  requires_external_evidence: boolean
  proposed_capability: string | null
```

Minimum validity: at least one evidence item; `retry` has at least one failure type; and `pass`/`skip` has no unresolved failure. `affects_semantics`, low confidence, or a missing/contradictory result must escalate instead of auto-rewriting. The controller validates this result; it does not infer that an LLM has run.

Review Result v2.1 is an accepted richer input for `pre_generation_prompt_review`. The controller validates its hashes, evidence, gate, fixture boundary, and explicit `controller_mapping`, then normalizes it to this assessment shape. It does not accept Gate 2 or Gate 3 results until their real-media implementations exist. Evaluator Result remains the compatibility input; it is not a second persisted Review authority.

Recommended evaluator instruction: assess only the named unit against its contract; cite observable evidence; choose one verdict; enumerate failures using the owning Skill taxonomy; never revise frozen semantic locks.
