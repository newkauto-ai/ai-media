[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw "ASSERTION FAILED: $Message" }
}

$root = Split-Path -Parent $PSScriptRoot
$pluginManifest = Get-Content -LiteralPath (Join-Path $root '.codex-plugin\plugin.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$skillsRoot = [System.IO.Path]::GetFullPath((Join-Path $root ([string]$pluginManifest.skills)))
Assert-True (Test-Path -LiteralPath $skillsRoot -PathType Container) 'Manifest-declared skills root is missing.'

$registry = Get-Content -LiteralPath (Join-Path $root 'style-profiles\registry.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$entries = @($registry.profiles | Where-Object { $_.profile_id -eq 'reference_video_structural_remake' })
Assert-True ($entries.Count -eq 1) 'The remake Profile must retain one active registry ID.'
$entry = $entries[0]
Assert-True ($entry.normalized_version -eq 'v1.1-zh' -and $entry.status -eq 'ready') 'The validated v1.1 Profile must be the ready registry target.'
$sourcePath = Join-Path $root (Join-Path 'style-profiles\source' $entry.source_file)
$normalizedPath = Join-Path $root (Join-Path 'style-profiles\normalized' $entry.normalized_file)
Assert-True ((Get-FileHash -Algorithm SHA256 -LiteralPath $sourcePath).Hash -eq $entry.source_sha256) 'Registry source hash is stale.'
Assert-True (Test-Path -LiteralPath (Join-Path $root 'style-profiles\source\Style_Profile_参考视频结构复刻_v1.0_中文解析.md')) 'v1.0 source must be preserved.'
Assert-True (Test-Path -LiteralPath (Join-Path $root 'style-profiles\normalized\reference_video_structural_remake.v1.0-zh.json')) 'v1.0 normalized profile must be preserved.'

$profile = (Get-Content -LiteralPath $normalizedPath -Raw -Encoding UTF8 | ConvertFrom-Json).style_profile
Assert-True ($profile.style_id -eq 'reference_video_structural_remake' -and $profile.version -eq 'v1.1-zh') 'Normalized Profile identity/version mismatch.'
Assert-True (-not $profile.defaults.real_media_fidelity_verified) 'A ready Profile must not claim real-media fidelity verification.'

$moduleOwners = [ordered]@{
    reference_compatibility = 'script-engine\SKILL.md'
    preservation_constraints = 'script-engine\SKILL.md'
    replacement_mapping = 'script-engine\SKILL.md'
    reference_evidence_record = 'audiovisual-director\contracts\audiovisual-direction-package.md'
    reference_structure_mapping = 'audiovisual-director\modules\audiovisual-beat-director.md'
    dynamic_relationship_plan = 'audiovisual-director\SKILL.md'
    sound_timing_basis = 'audiovisual-director\SKILL.md'
    reference_asset_binding = 'video-production\modules\asset-reference-router.md'
    reference_fidelity_trace = 'video-production\contracts\production-manifest.md'
    reference_fidelity_assessment = 'workflow-controller\contracts\evaluator-result.md'
}
foreach ($module in $moduleOwners.Keys) {
    $ownerText = Get-Content -LiteralPath (Join-Path $skillsRoot $moduleOwners[$module]) -Raw -Encoding UTF8
    Assert-True ($ownerText.Contains($module)) "Critical module '$module' is not consumed by its declared manifest-route owner."
}

$cases = Get-Content -LiteralPath (Join-Path $root 'tests\fixtures\reference-video-structural-remake-cases.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$pipeline = $cases.pipeline_case
Assert-True ($pipeline.script_handoff.reference_fidelity.constraint_hash -eq $pipeline.adp.reference_fidelity.constraint_hash) 'Script -> ADP constraint hash was not preserved.'
Assert-True ($pipeline.adp.reference_fidelity.constraint_hash -eq $pipeline.manifest.reference_fidelity.constraint_hash) 'ADP -> Manifest constraint hash was not preserved.'
$mapping = @($pipeline.script_handoff.reference_fidelity.reference_structure_mapping)
Assert-True ($mapping.Count -eq 4) 'Four-unit non-narrative reference must remain four ordered units.'
Assert-True ((@($mapping.order) -join ',') -eq '1,2,3,4') 'Reference order changed during adaptation mapping.'
Assert-True ($pipeline.script_handoff.selected_hook_preserved -and $pipeline.script_handoff.hcerm -eq 'not_applicable' -and -not $pipeline.script_handoff.invented_reversal) 'Reference branch invented generic narrative structure.'
Assert-True (@($pipeline.adp.audiovisual_beat_ids).Count -eq 4) 'Reference branch padded the four-unit source to a generic 8-12 Beat count.'

$criticalIds = @($pipeline.manifest.reference_fidelity.critical_requirement_ids)
$traceIds = @($pipeline.adp.reference_fidelity_traces | ForEach-Object { $_.requirement_id })
foreach ($id in $criticalIds) { Assert-True ($traceIds -contains $id) "Critical requirement '$id' lost before production." }
$clipRefs = @($pipeline.manifest.clips | ForEach-Object { @($_.reference_fidelity_trace_refs) } | ForEach-Object { $_ })
foreach ($id in $criticalIds) { Assert-True ($clipRefs -contains $id) "Critical requirement '$id' has no production binding." }

$still = $cases.evidence_cases | Where-Object { $_.case_id -eq 'still_only' }
Assert-True ($still.observations.composition -eq 'observed' -and $still.observations.visible_state -eq 'observed') 'Still evidence should retain observable static facts.'
foreach ($dimension in @('motion','rhythm','sound','synchronization')) { Assert-True ($still.observations.$dimension -eq 'UNKNOWN') "Still evidence fabricated $dimension." }

$changed = $cases.evidence_cases | Where-Object { $_.case_id -eq 'constraint_hash_changed' }
$isStale = $changed.previous_constraint_hash -ne $changed.current_constraint_hash
Assert-True ($isStale -and $changed.expected_current_assessment -eq 'stale' -and $changed.expected_retry_delta -eq 0) 'Constraint change must stale old QA without consuming retry.'

$retimed = $cases.evidence_cases | Where-Object { $_.case_id -eq 'reveal_retimed_but_output_kept_source_time' }
$timingDelta = [math]::Abs([double]$retimed.observed_timing_seconds - [double]$retimed.target_timing_seconds)
Assert-True ($timingDelta -gt [double]$retimed.tolerance_seconds -and $retimed.expected_status -eq 'fail' -and $retimed.expected_failure_type -eq 'timing_failure') 'Observed source-time reveal must fail the retimed target requirement.'

$subtitle = $cases.evidence_cases | Where-Object { $_.case_id -eq 'subtitle_only_defect' }
Assert-True ($subtitle.core_story_function_satisfied -and $subtitle.can_edit_or_reuse -and $subtitle.expected_next_action -eq 'edit_or_reuse_failed_unit') 'Subtitle-only defect must route to local edit/reuse.'
$missing = $cases.evidence_cases | Where-Object { $_.case_id -eq 'missing_real_output_media' }
Assert-True ($null -eq $missing.target_media_path -and $null -eq $missing.target_media_hash -and $missing.expected_status -eq 'unknown' -and $missing.expected_retry_delta -eq 0 -and -not $missing.may_claim_real_media_pass) 'Missing real output must remain unknown without retry or PASS.'

Write-Output 'PASS: reference-video structural-remake v1.1 preserves one Profile ID, manifest-route module ownership, four-unit non-narrative structure, evidence limits, hash invalidation, retimed reveal detection, and bounded QA routing.'
