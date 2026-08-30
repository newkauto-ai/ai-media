[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$FixturePath,

    [Parameter(Mandatory = $true)]
    [string]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-TextSha256 {
    param([string]$Text)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
        return ([System.BitConverter]::ToString($sha.ComputeHash($bytes))).Replace('-', '').ToLowerInvariant()
    }
    finally { $sha.Dispose() }
}

function Require-Field {
    param([object]$Object, [string]$Field, [string]$Context)
    if ($null -eq $Object.PSObject.Properties[$Field] -or $null -eq $Object.$Field) {
        throw "$Context.$Field is required."
    }
}

if (-not (Test-Path -LiteralPath $FixturePath -PathType Leaf)) { throw "Fixture not found: $FixturePath" }
$fixture = Get-Content -LiteralPath $FixturePath -Raw -Encoding UTF8 | ConvertFrom-Json
if ([string]$fixture.contract_version -ne '1.0') { throw 'Storyboard fixture contract_version must be 1.0.' }

$requiredPanelFields = @(
    'panel_id', 'source_refs', 'time_range', 'narrative_function', 'assigned_hook',
    'assigned_turning_point', 'assigned_payoff', 'named_risk_reduced', 'core_visual_event',
    'shot_size_and_composition', 'character_position', 'action_and_expression',
    'environment_key_elements', 'lighting_and_mood', 'continuity_notes', 'non_realistic_aids'
)
$compiledCases = @()

foreach ($case in @($fixture.cases)) {
    foreach ($field in @('case_id', 'stage1_approved', 'production_risk', 'risk_triggers', 'evidence_refs', 'panels')) {
        Require-Field $case $field "case"
    }
    if (-not [bool]$case.stage1_approved) { throw "$($case.case_id): Stage 1 approval is required before Storyboard planning." }
    if ([string]$case.production_risk -notin @('low', 'medium', 'high')) { throw "$($case.case_id): invalid production_risk." }
    if (@($case.evidence_refs).Count -lt 1) { throw "$($case.case_id): applicability requires evidence." }

    $triggers = @($case.risk_triggers | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) })
    $retain = ([string]$case.production_risk -in @('medium', 'high')) -or $triggers.Count -gt 0
    $decision = if ($retain) { 'retain' } else { 'skip' }
    $reasons = if ($retain) {
        @("production_risk=$($case.production_risk)") + @($triggers)
    }
    else {
        @('production_risk=low', 'no_named_storyboard_trigger')
    }

    if (-not $retain) {
        if (@($case.panels).Count -ne 0) { throw "$($case.case_id): a skip case may not fabricate Storyboard panels." }
        $compiledCases += [pscustomobject]@{
            case_id = [string]$case.case_id
            previsualization = [pscustomobject]@{
                fixture_only = $true
                applicability = [pscustomobject]@{ decision = 'skip'; production_risk = [string]$case.production_risk; reasons = $reasons; evidence_refs = @($case.evidence_refs) }
                storyboard_plan = $null
                prompt_ref = $null
                asset_ref = $null
                review_result_ref = $null
                generation_status = 'not_required'
                cost_gate = [pscustomobject]@{ state = 'not_required'; approval_evidence = $null }
            }
            contact_sheet_prompt = $null
            single_panel_repair = $null
        }
        continue
    }

    $panels = @($case.panels)
    if ($panels.Count -lt 1) { throw "$($case.case_id): retain requires at least one risk-selected Panel." }
    $panelIds = @()
    foreach ($panel in $panels) {
        foreach ($field in $requiredPanelFields) { Require-Field $panel $field "$($case.case_id).panel" }
        if ([string]::IsNullOrWhiteSpace([string]$panel.panel_id)) { throw "$($case.case_id): panel_id may not be blank." }
        if ($panelIds -contains [string]$panel.panel_id) { throw "$($case.case_id): duplicate panel_id $($panel.panel_id)." }
        $panelIds += [string]$panel.panel_id
        if (@($panel.source_refs.script_refs).Count -eq 0 -and @($panel.source_refs.adp_beat_refs).Count -eq 0) {
            throw "$($case.case_id).$($panel.panel_id): Script or ADP source reference is required."
        }
        if (@($panel.named_risk_reduced).Count -eq 0) { throw "$($case.case_id).$($panel.panel_id): named risk is required." }
    }

    $planPayload = [ordered]@{
        case_id = [string]$case.case_id
        production_risk = [string]$case.production_risk
        risk_triggers = @($triggers)
        panels = @($panels)
    }
    $planJson = $planPayload | ConvertTo-Json -Depth 20 -Compress
    $planHash = Get-TextSha256 $planJson
    $planRevision = "storyboard-$($case.case_id)-r1"

    $panelBlocks = @($panels | ForEach-Object {
        $aids = if (@($_.non_realistic_aids).Count) { @($_.non_realistic_aids) -join ', ' } else { 'none' }
        "[$($_.panel_id)] function=$($_.narrative_function); event=$($_.core_visual_event); composition=$($_.shot_size_and_composition); position=$($_.character_position); action=$($_.action_and_expression); environment=$($_.environment_key_elements); mood=$($_.lighting_and_mood); continuity=$(@($_.continuity_notes) -join ', '); aids=$aids"
    })
    $anchors = @($case.consistency_anchors)
    if ($anchors.Count -eq 0) { $anchors = @('Use only the supplied Script and ADP identity/continuity references.') }
    $outputSpec = if ([string]::IsNullOrWhiteSpace([string]$case.output_spec)) { 'One readable contact sheet; layout selected to fit the risk-selected Panel count.' } else { [string]$case.output_spec }
    $prompt = @(
        'Create one ordered storyboard contact sheet for previsualization only.'
        ''
        'Project anchors:'
        ($anchors -join [Environment]::NewLine)
        ''
        'Panels in reading order:'
        ($panelBlocks -join [Environment]::NewLine)
        ''
        'Keep every Panel ID and reading order. Preserve only supplied composition, action, position, environment, mood, continuity, and assigned story function.'
        'Use simplified detail. Do not invent plot, motives, characters, props, dialogue, transitions, or spectacle.'
        'This is previsualization, not a Production Asset, Visual Baseline, poster, or provider-specific prompt.'
        'Do not add subtitles, decorative text, watermarks, logos, or finished typography.'
        "Output: $outputSpec"
        'Stopping condition: return one contact sheet only; no variants or automatic regeneration.'
    ) -join [Environment]::NewLine
    $promptHash = Get-TextSha256 $prompt

    $singlePanelRepair = $null
    $repairProperty = $case.PSObject.Properties['repair_request']
    if ($null -ne $repairProperty -and $null -ne $repairProperty.Value) {
        $repair = $repairProperty.Value
        foreach ($field in @('panel_id', 'failure_type', 'evidence', 'repair_target')) { Require-Field $repair $field "$($case.case_id).repair_request" }
        $targetPanel = @($panels | Where-Object { [string]$_.panel_id -eq [string]$repair.panel_id }) | Select-Object -First 1
        if ($null -eq $targetPanel) { throw "$($case.case_id): repair Panel does not exist." }
        if (@($repair.evidence).Count -eq 0) { throw "$($case.case_id): repair requires evidence." }
        $preserved = @($panelIds | Where-Object { $_ -ne [string]$repair.panel_id })
        $repairPrompt = @(
            "Repair only Panel $($repair.panel_id) from revision $planRevision."
            "Must Fix: $($repair.failure_type)."
            "Evidence: $(@($repair.evidence) -join '; ')."
            "Repair target: $($repair.repair_target)."
            "Preserve all other Panels by reference: $($preserved -join ', ')."
            'Do not redesign the full Storyboard or change frozen Script/ADP semantics.'
            'A real generation call requires a new separate Cost Gate.'
        ) -join [Environment]::NewLine
        $singlePanelRepair = [pscustomobject]@{
            panel_id = [string]$repair.panel_id
            source_plan_revision_id = $planRevision
            failure_type = [string]$repair.failure_type
            evidence = @($repair.evidence)
            repair_target = [string]$repair.repair_target
            preserved_panel_refs = $preserved
            executable_prompt_preview = $repairPrompt
            prompt_content_hash = Get-TextSha256 $repairPrompt
            generation_status = 'planned_awaiting_cost_gate'
        }
    }

    $compiledCases += [pscustomobject]@{
        case_id = [string]$case.case_id
        previsualization = [pscustomobject]@{
            fixture_only = $true
            applicability = [pscustomobject]@{ decision = $decision; production_risk = [string]$case.production_risk; reasons = $reasons; evidence_refs = @($case.evidence_refs) }
            storyboard_plan = [pscustomobject]@{ plan_id = "plan-$($case.case_id)"; revision_id = $planRevision; content_hash = $planHash; panel_refs = $panelIds; panels = $panels }
            prompt_ref = [pscustomobject]@{ prompt_id = "contact-sheet-$($case.case_id)"; revision_id = "$planRevision-prompt"; content_hash = $promptHash }
            asset_ref = $null
            review_result_ref = $null
            generation_status = 'planned_awaiting_cost_gate'
            cost_gate = [pscustomobject]@{ state = 'awaiting_user_approval'; minimum_generation_set = @("contact-sheet-$($case.case_id)"); model = $null; quantity = 1; estimated_cost = $null; stopping_condition = 'Stop after one approved Contact Sheet; no variants or automatic panel regeneration.'; approval_evidence = $null }
        }
        contact_sheet_prompt = $prompt
        single_panel_repair = $singlePanelRepair
    }
}

$result = [pscustomobject]@{
    contract_version = '1.0'
    fixture_only = $true
    external_generation_called = $false
    human_approval_written = $false
    actual_state_written = $false
    cost_gate_granted = $false
    cases = $compiledCases
}
$outputParent = Split-Path -Parent $OutputPath
if ($outputParent -and -not (Test-Path -LiteralPath $outputParent)) { New-Item -ItemType Directory -Force -Path $outputParent | Out-Null }
$result | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
Write-Output "PASS: Storyboard previsualization fixture compiled without external generation: $OutputPath"
