[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw "ASSERTION FAILED: $Message" }
}

$root = Split-Path -Parent $PSScriptRoot
$fixturePath = Join-Path $root 'tests\fixtures\image-prompt-cases.json'
$compilerPath = Join-Path $root 'video-production\scripts\compile-image-prompt-fixture.ps1'
$tempDirectory = Join-Path ([System.IO.Path]::GetTempPath()) ('image-prompt-fixture-' + [guid]::NewGuid().ToString('N'))
$outputPath = Join-Path $tempDirectory 'compiled.json'

try {
    & $compilerPath -FixturePath $fixturePath -OutputPath $outputPath
    $result = Get-Content -LiteralPath $outputPath -Raw -Encoding UTF8 | ConvertFrom-Json
    Assert-True ($result.fixture_only -and -not $result.external_generation_called) 'Image fixture must remain local and non-generative.'
    Assert-True ($result.cases.Count -eq 11) 'Fixture must retain legacy cases and add one non-generative VOX atlas projection case.'
    foreach ($case in $result.cases) {
        $spec = $case.image_prompt_spec
        $isPassed = $spec.qa.status -eq 'passed'
        Assert-True (($case.expected_result -eq 'passed') -eq $isPassed) "$($case.case_id): fixture result did not match expectation."
        $expectedVersion = if ($spec.prompt_variant -eq 'cover_visual') { '1.2' } else { '1.1' }
        Assert-True ($spec.contract_version -eq $expectedVersion) "$($case.case_id): Image Prompt Spec version must preserve legacy compatibility and version cover_visual."
        foreach ($name in @('subject_action', 'context', 'composition_camera', 'lighting_outcome', 'style_aesthetic', 'optics', 'color')) {
            $decision = $spec.decisions.$name
            Assert-True ($decision.status -in @('explicit', 'inherited', 'not_applicable')) "$($case.case_id): $name lacks a legal status."
            if ($decision.status -eq 'inherited') { Assert-True (-not [string]::IsNullOrWhiteSpace([string]$decision.inherited_from)) "$($case.case_id): inherited $name lacks source." }
            if ($decision.status -eq 'not_applicable') { Assert-True (-not [string]::IsNullOrWhiteSpace([string]$decision.reason)) "$($case.case_id): not-applicable $name lacks reason." }
        }
        Assert-True ($spec.clause_decision_map.Count -gt 0) "$($case.case_id): every prompt needs a clause map."
        Assert-True (@($spec.clause_decision_map | Where-Object { $_.decision_paths.Count -eq 0 }).Count -eq 0) "$($case.case_id): a prompt clause lacks decision or QA mapping."
        Assert-True ($case.call_package.generation_status -eq 'blocked') "$($case.case_id): fixture may not become generation-ready."
    }

    $character = $result.cases | Where-Object { $_.case_id -eq 'character-transparent-neutral' } | Select-Object -First 1
    Assert-True ($character.image_prompt_spec.executable_prompt -match '年轻僧人角色' -and $character.image_prompt_spec.executable_prompt -notmatch '山路|驿站') 'Character must start with neutral identity task and avoid scene action.'
    Assert-True ($character.call_package.request_parameters.background -eq 'transparent') 'Explicit transparent background must reach the call package.'

    $product = $result.cases | Where-Object { $_.case_id -eq 'product-evidence-laptop' } | Select-Object -First 1
    Assert-True ($product.image_prompt_spec.executable_prompt -match '低畸变正常透视' -and $product.image_prompt_spec.executable_prompt -match 'US QWERTY' -and $product.image_prompt_spec.executable_prompt -match '右掌托细小划痕') 'Product evidence must compile optics and inspected locks.'
    $graphic = $result.cases | Where-Object { $_.case_id -eq 'graphic-text-reserve' } | Select-Object -First 1
    Assert-True ($graphic.image_prompt_spec.decisions.optics.status -eq 'not_applicable' -and $graphic.image_prompt_spec.executable_prompt -match '后期排字') 'Graphic must keep optics out and route exact text to post.'
    $keyframe = $result.cases | Where-Object { $_.case_id -eq 'keyframe-current-first' } | Select-Object -First 1
    Assert-True ($keyframe.image_prompt_spec.executable_prompt.IndexOf('僧人站在石阶中段') -lt $keyframe.image_prompt_spec.executable_prompt.IndexOf('参考绑定')) 'Keyframe current frame must precede reference responsibilities.'
    $colorConflict = $result.cases | Where-Object { $_.case_id -eq 'product-grade-conflict' } | Select-Object -First 1
    Assert-True ($colorConflict.image_prompt_spec.qa.failures -contains 'consistency_lock_violation') 'Grade changing true product color must fail closed.'
    $opticsConflict = $result.cases | Where-Object { $_.case_id -eq 'product-optics-not-applicable' } | Select-Object -First 1
    Assert-True ($opticsConflict.image_prompt_spec.qa.failures -contains 'prompt_under_specified') 'Product evidence cannot mark optics not applicable.'
    $xhsCover = $result.cases | Where-Object { $_.case_id -eq 'cover-visual-xiaohongshu' } | Select-Object -First 1
    $douyinCover = $result.cases | Where-Object { $_.case_id -eq 'cover-visual-douyin' } | Select-Object -First 1
    Assert-True ($xhsCover.image_prompt_spec.executable_prompt -match '目标平台：xiaohongshu' -and $xhsCover.image_prompt_spec.executable_prompt -match 'generate_text_in_image=false|只生成无文字底图') 'Xiaohongshu cover_visual must compile platform and post-layout text constraints.'
    Assert-True ($douyinCover.image_prompt_spec.executable_prompt -match '目标平台：douyin' -and $xhsCover.image_prompt_spec.executable_prompt -ne $douyinCover.image_prompt_spec.executable_prompt) 'Douyin cover_visual must compile an independent platform-native prompt.'
    $atlas = $result.cases | Where-Object { $_.case_id -eq 'vox-manual-2x2-atlas-projection' } | Select-Object -First 1
    Assert-True ($null -ne $atlas.atlas_prompt_projection) 'VOX atlas case must compile a temporary projection.'
    Assert-True ($atlas.atlas_prompt_projection.projection_type -eq 'manual_cutout_from_named_2x2_atlas' -and $atlas.atlas_prompt_projection.grid -eq '2x2') 'Atlas projection must use the bounded named 2x2 route.'
    Assert-True ($atlas.atlas_prompt_projection.source_asset_ids.Count -eq 3 -and $atlas.atlas_prompt_projection.cells.Count -eq 3) 'Atlas must retain planned source IDs and leave the fourth cell empty rather than duplicate content.'
    Assert-True ($atlas.atlas_prompt_projection.background.type -eq 'solid_color' -and $atlas.atlas_prompt_projection.layout_constraints.no_in_image_labels) 'Atlas must require a solid background and no in-image labels.'
    Assert-True ($atlas.atlas_prompt_projection.call_package.generation_status -eq 'blocked' -and $atlas.atlas_prompt_projection.handoff.remotion_input -eq 'individual_rgba_png_only') 'Atlas projection must stay blocked until separate RGBA PNG intake.'
    Assert-True ($atlas.atlas_prompt_projection.persistence -match 'not_production_manifest_or_asset') 'Atlas projection must not become a Manifest asset.'

    Write-Output 'PASS: Image Prompt contracts validate legacy templates, cover composition, and the blocked ephemeral VOX 2x2 atlas projection without generation or Manifest persistence.'
}
finally {
    if (Test-Path -LiteralPath $tempDirectory) { Remove-Item -LiteralPath $tempDirectory -Recurse -Force }
}
