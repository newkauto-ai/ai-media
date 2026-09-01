[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw "ASSERTION FAILED: $Message" }
}

$root = Split-Path -Parent $PSScriptRoot
$fixture = Get-Content -LiteralPath (Join-Path $root 'tests\fixtures\activation-intent-cases.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$routePolicy = Get-Content -LiteralPath (Join-Path $root 'workflow-controller\policies\route-policy.md') -Raw -Encoding UTF8
$controllerSkill = Get-Content -LiteralPath (Join-Path $root 'workflow-controller\SKILL.md') -Raw -Encoding UTF8

Assert-True ($fixture.contract_version -eq '1.0') 'Activation intent fixture contract version must be 1.0.'
Assert-True ($fixture.cases.Count -eq 10) 'Activation contract requires exactly the ten frozen minimum cases.'

$requiredIds = @(
    'resume_consistent_project', 'reported_media_missing_from_manifest',
    'claimed_frozen_script_file_missing', 'script_hash_changed_prompt_review_stale',
    'stage0_waiting_user_says_continue', 'stage0_exact_approval',
    'accepted_media_target_ambiguous', 'propagate_all_clips_no_cost_scope',
    'simple_contract_question', 'user_stop'
)
$allowedSurfaceModes = @('indirect', 'direct', 'negative')
$allowedEntries = @('controller', 'specialist_direct', 'stop')

foreach ($case in $fixture.cases) {
    foreach ($field in @('case_id','surface_mode','intent','project_context','observation','expected_entry','expected_route','expected_stop_reason')) {
        Assert-True ($null -ne $case.$field) "$($case.case_id): missing required field '$field'."
    }
    Assert-True ($allowedSurfaceModes -contains $case.surface_mode) "$($case.case_id): invalid surface_mode."
    Assert-True ($allowedEntries -contains $case.expected_entry) "$($case.case_id): invalid expected_entry."
    Assert-True (-not [string]::IsNullOrWhiteSpace([string]$case.expected_route)) "$($case.case_id): expected_route is required."
    Assert-True (-not [string]::IsNullOrWhiteSpace([string]$case.expected_stop_reason)) "$($case.case_id): expected_stop_reason is required."
}

Assert-True ((@($fixture.cases.case_id | Sort-Object) -join ',') -eq (@($requiredIds | Sort-Object) -join ',')) 'Activation fixture IDs do not match the frozen minimum set.'
Assert-True ($routePolicy -match 'media-intake') 'Route Policy must cover unbound reported media intake.'
Assert-True ($routePolicy -match 'generic “continue” is insufficient') 'Route Policy must preserve explicit Stage confirmation.'
Assert-True ($routePolicy -match 'do not batch automatically') 'Route Policy must preserve Clip-first and Cost Gate boundaries.'
Assert-True ($controllerSkill -match 'Natural-language intent is sufficient') 'Controller activation must support indirect natural-language entry.'
Assert-True ($controllerSkill -match 'It is not a second persistent state source') 'Reconciliation must not create a second state owner.'
Assert-True ($controllerSkill -match 'must not create `actual_end_state`') 'Reported-media intake must not manufacture selected continuity state.'

Write-Output 'PASS: 10 activation intent contract cases preserve Controller entry, bounded reconciliation, one-action routing, Stage/Cost Gates, direct-specialist exceptions, and user stop.'
