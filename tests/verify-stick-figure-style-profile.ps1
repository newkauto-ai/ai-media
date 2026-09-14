$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}

$pluginRoot = Split-Path -Parent $PSScriptRoot
$registryPath = Join-Path $pluginRoot 'style-profiles\registry.json'
$registry = Get-Content -Raw -Encoding UTF8 -LiteralPath $registryPath | ConvertFrom-Json
$entry = @($registry.profiles | Where-Object { $_.profile_id -eq 'minimal_stick_figure_explainer_story' })
Assert-True ($entry.Count -eq 1) 'Expected one minimal_stick_figure_explainer_story registry entry.'
$entry = $entry[0]
Assert-True ($entry.normalized_version -eq 'v1.3-zh') 'Stick-figure registry must point to v1.3-zh.'
Assert-True ($entry.status -eq 'ready') 'Stick-figure profile must be ready.'

$sourcePath = Join-Path $pluginRoot (Join-Path 'style-profiles\source' $entry.source_file)
$normalizedPath = Join-Path $pluginRoot (Join-Path 'style-profiles\normalized' $entry.normalized_file)
Assert-True (Test-Path -LiteralPath $sourcePath -PathType Leaf) 'Stick-figure source profile is missing.'
Assert-True (Test-Path -LiteralPath $normalizedPath -PathType Leaf) 'Stick-figure normalized profile is missing.'
Assert-True ((Get-FileHash -Algorithm SHA256 -LiteralPath $sourcePath).Hash -eq $entry.source_sha256) 'Stick-figure source hash does not match registry.'

$normalized = Get-Content -Raw -Encoding UTF8 -LiteralPath $normalizedPath | ConvertFrom-Json
$visual = $normalized.style_profile.visual
$order = @($normalized.style_profile.visual.character_or_animal_draw_order)
Assert-True ($visual.head_first_required -eq $true) 'head_first_required must be true.'
Assert-True (($order -join ',') -eq 'character_head,character_body,character_limbs_or_accessories') 'Character/animal draw order must be head, body, then limbs/accessories.'
Assert-True ($visual.color_fill_mode -eq 'single_tone_flat_fill_per_semantic_region') 'Each semantic region must use single-tone flat fill.'
Assert-True ($visual.secondary_shading_allowed -eq $false) 'Cel-shading second tone must be disabled.'
Assert-True ($visual.gradient_allowed -eq $false) 'Gradients must be disabled.'
Assert-True ($visual.color_only_shadow_layer_allowed -eq $false) 'Color-only shadow layers must be disabled.'
Assert-True ($visual.direct_fill_allowed -eq $false) 'direct_fill exceptions must be disabled for this profile.'
Assert-True ($visual.character_design_diversity_required -eq $true) 'Character design diversity must be required.'
Assert-True ($visual.minimum_distinct_design_axes_per_character_pair -eq 3) 'Each main character pair must differ on at least three design axes.'
$diversityAxes = @($visual.character_design_diversity_axes)
Assert-True ($diversityAxes.Count -eq 6) 'Expected six auditable character design axes.'
Assert-True ($visual.color_swap_only_is_valid_character_difference -eq $false) 'A color swap alone must not count as character diversity.'
Assert-True ($visual.same_character_identity_consistency_required -eq $true) 'The same character identity must remain consistent across shots.'
Assert-True ($visual.hands_and_feet_required -eq $true) 'Hands and feet must be explicit.'
Assert-True ($visual.limb_line_width_output_px -eq '3.5-5') 'Limbs must use the thicker secondary line tier.'

$manifest = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $pluginRoot '.codex-plugin\plugin.json') | ConvertFrom-Json
$skillsRoot = [System.IO.Path]::GetFullPath((Join-Path $pluginRoot ([string]$manifest.skills)))
$productionCli = Join-Path $skillsRoot 'video-production\scripts\whiteboard-production-cli.ps1'
Assert-True (Test-Path -LiteralPath $productionCli -PathType Leaf) 'Manifest-declared whiteboard production CLI is missing.'

$tempBase = [System.IO.Path]::GetTempPath()
$tempRoot = Join-Path $tempBase ('codex-stick-figure-style-' + [guid]::NewGuid().ToString('N'))
try {
    New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null
    $requestPath = Join-Path $tempRoot 'request.json'
    $outputPath = Join-Path $tempRoot 'style-slice.json'
    $request = @{ registry_path = $registryPath; profile_id = $entry.profile_id } | ConvertTo-Json
    [System.IO.File]::WriteAllText($requestPath, $request, [System.Text.UTF8Encoding]::new($false))
    & $productionCli -Action map-style -Request $requestPath -Output $outputPath | Out-Null
    Assert-True ($LASTEXITCODE -eq 0) 'Style Slice mapping failed.'
    $slice = Get-Content -Raw -Encoding UTF8 -LiteralPath $outputPath | ConvertFrom-Json
    Assert-True ($slice.compatibility -eq 'compatible') 'Stick-figure Style Slice must remain compatible.'
    $requiredVisualPaths = @(
        'visual.color_fill_mode',
        'visual.secondary_shading_allowed',
        'visual.gradient_allowed',
        'visual.color_only_shadow_layer_allowed',
        'visual.direct_fill_allowed',
        'visual.character_design_diversity_required',
        'visual.minimum_distinct_design_axes_per_character_pair',
        'visual.color_swap_only_is_valid_character_difference',
        'visual.same_character_identity_consistency_required',
        'visual.hands_and_feet_required',
        'visual.limb_line_width_output_px',
        'visual.head_first_required'
    )
    foreach ($requiredPath in $requiredVisualPaths) {
        Assert-True (@($slice.accepted_fields | Where-Object { $_.source_path -eq $requiredPath }).Count -eq 1) "Style Slice must retain $requiredPath."
    }
    $acceptedOrder = @($slice.accepted_fields | Where-Object { $_.source_path -match '^visual\.character_or_animal_draw_order\[[0-2]\]$' })
    Assert-True ($acceptedOrder.Count -eq 3) 'Style Slice must retain the three head-first order entries.'
    $acceptedAxes = @($slice.accepted_fields | Where-Object { $_.source_path -match '^visual\.character_design_diversity_axes\[[0-5]\]$' })
    Assert-True ($acceptedAxes.Count -eq 6) 'Style Slice must retain all six character-diversity axes.'
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        $resolvedBase = [System.IO.Path]::GetFullPath($tempBase)
        $resolvedTarget = [System.IO.Path]::GetFullPath($tempRoot)
        Assert-True ($resolvedTarget.StartsWith($resolvedBase, [System.StringComparison]::OrdinalIgnoreCase)) 'Refusing to remove a test directory outside temp.'
        Remove-Item -LiteralPath $resolvedTarget -Recurse -Force
    }
}

Write-Output 'PASS: Stick-figure v1.3 enforces single-tone flat fill, diverse character silhouettes, explicit hands/feet, thicker limbs, and head-first drawing through the manifest Style Slice entry.'
