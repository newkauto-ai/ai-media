# Platform Profile Contract v1.1

Platform profiles are local JSON snapshots. Every decision-bearing rule carries field-level provenance and freshness; top-level `last_verified` is only a summary.

```yaml
platform_profile:
  schema_version: "1.1"
  profile_id: string
  profile_version: string
  platform: xiaohongshu | douyin | youtube_shorts | youtube_long
  last_verified: datetime
  rules:
    - rule_id: string
      field: string
      value: any
      rule_type: hard_spec | policy | disclosure | capability | heuristic
      critical: boolean
      source_url: string
      source_type: official | account_analytics | observed_test | secondary
      verified_at: datetime
      scope: {region, account_type, content_type, interface}
      status: current | stale | unknown | contradicted
      review_after: date | null
      confidence: high | medium | low | unknown
      notes: string | null
```

At runtime, a rule marked `current` becomes `stale` after `review_after`. A critical hard spec, policy, disclosure, or capability rule that is stale, unknown, or contradicted withholds Ready. A stale heuristic may fall back conservatively but lowers timing/performance confidence. Missing account analytics can never produce a high-confidence time window.

Dimensions, title limits, AI disclosure, upload capability, and platform policy are versioned profile data rather than permanent engine constants. Local profile evidence never grants OAuth scopes, account authorization, API access, or publishing permission.
