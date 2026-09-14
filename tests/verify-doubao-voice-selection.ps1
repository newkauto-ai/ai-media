[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw "ASSERTION FAILED: $Message" }
}

$root = Split-Path -Parent $PSScriptRoot
$fixture = Join-Path $root 'tests\fixtures\doubao-voice-requirements.fixture.json'
$selector = Join-Path $root 'video-production\scripts\select-doubao-voices.ps1'
$mirrorSelector = Join-Path $root 'skills\video-production\scripts\select-doubao-voices.ps1'
$database = Join-Path $root 'video-production\data\voice-types.json'
$mirrorDatabase = Join-Path $root 'skills\video-production\data\voice-types.json'

$result = (& $selector -RequirementsPath $fixture -TopK 3 -Json) | ConvertFrom-Json
Assert-True ($result.schema_version -eq '1.0') 'Selector output schema must be explicit.'
Assert-True ($result.status -eq 'blocked') 'Any role without a hard-constraint match must block the package.'

$sichuan = $result.roles | Where-Object voice_profile_id -eq 'narrator-sichuan-male'
Assert-True ($sichuan.status -eq 'shortlist_partial_requires_human_review') 'Two eligible Sichuan male voices should produce a partial shortlist.'
Assert-True ($sichuan.requirement_provenance -eq 'source_locked') 'Source-defined role requirements must preserve provenance.'
Assert-True ($sichuan.candidates.Count -eq 2) 'Sichuan male hard constraints must leave exactly two curated candidates.'
Assert-True ($sichuan.candidates[0].voice_type -eq 'zh_male_m191_uranus_bigtts') 'Yunzhou 2.0 should rank first for the mature, steady Sichuan narration fixture.'
Assert-True (@($sichuan.candidates | Where-Object { $_.gender -ne 'male' -or 'sichuan' -notin $_.dialects }).Count -eq 0) 'Every Sichuan shortlist item must satisfy gender and dialect hard constraints.'
Assert-True (@($sichuan.candidates | Where-Object account_availability -ne 'unknown').Count -eq 0) 'Public catalog candidates must not imply account entitlement.'
Assert-True ($null -eq $sichuan.selected_voice -and -not $sichuan.provider_call_authorized) 'Recommendation must not auto-select or authorize a provider call.'

$grandmother = $result.roles | Where-Object voice_profile_id -eq 'grandmother-main'
Assert-True ($grandmother.candidates[0].voice_type -eq 'zh_female_popo_uranus_bigtts') 'Age and dialogue preferences should rank Grandmother 2.0 first.'

$unsupported = $result.roles | Where-Object voice_profile_id -eq 'unsupported-hakka-male'
Assert-True ($unsupported.status -eq 'blocked_no_candidate' -and $unsupported.candidates.Count -eq 0) 'Unsupported dialects must not be silently relaxed.'

Assert-True ((Get-FileHash -Algorithm SHA256 $selector).Hash -eq (Get-FileHash -Algorithm SHA256 $mirrorSelector).Hash) 'Selector root and manifest Skill copies must match.'
Assert-True ((Get-FileHash -Algorithm SHA256 $database).Hash -eq (Get-FileHash -Algorithm SHA256 $mirrorDatabase).Hash) 'Voice catalogs must match across root and manifest Skill copies.'

Write-Output 'PASS: Doubao voice selection hard-filters role requirements, ranks a bounded shortlist, preserves account uncertainty, and requires human approval.'
