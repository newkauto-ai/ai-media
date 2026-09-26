[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$FixturePath,

    [Parameter(Mandatory = $true)]
    [string]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-Value {
    param([object]$Object, [string]$Name)
    if ($null -eq $Object) { return $null }
    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property) { return $null }
    return $property.Value
}

function As-Array {
    param([object]$Value)
    if ($null -eq $Value) { return @() }
    return @($Value)
}

function Has-Text {
    param([object]$Value)
    return -not [string]::IsNullOrWhiteSpace([string]$Value)
}

function Add-Failure {
    param([System.Collections.Generic.List[string]]$Failures, [string]$Failure)
    if (-not $Failures.Contains($Failure)) { [void]$Failures.Add($Failure) }
}

function Test-Decision {
    param([object]$Decision, [string]$Path, [System.Collections.Generic.List[string]]$Failures)
    $status = [string](Get-Value $Decision 'status')
    if ($status -notin @('explicit', 'inherited', 'not_applicable')) {
        Add-Failure $Failures 'prompt_under_specified'
        return
    }
    if ($status -eq 'explicit' -and -not (Has-Text (Get-Value $Decision 'value'))) { Add-Failure $Failures 'prompt_under_specified' }
    if ($status -eq 'inherited' -and -not (Has-Text (Get-Value $Decision 'inherited_from'))) { Add-Failure $Failures 'prompt_under_specified' }
    if ($status -eq 'not_applicable' -and -not (Has-Text (Get-Value $Decision 'reason'))) { Add-Failure $Failures 'prompt_under_specified' }
}

function Get-DecisionText {
    param([object]$Decision)
    if ([string](Get-Value $Decision 'status') -eq 'inherited') { return [string](Get-Value $Decision 'value') }
    return [string](Get-Value $Decision 'value')
}

function Join-Values {
    param([object]$Values)
    return ((As-Array $Values) | ForEach-Object { [string]$_ }) -join '、'
}

function Format-ReferenceBindings {
    param([object]$Values)
    $formatted = foreach ($value in (As-Array $Values)) {
        if ($value -is [string]) { $value }
        else {
            $role = [string](Get-Value $value 'reference_role')
            $asset = [string](Get-Value $value 'asset_id')
            $version = [string](Get-Value $value 'version')
            $checksum = [string](Get-Value $value 'checksum_sha256')
            "$role=$asset@$version#$checksum"
        }
    }
    return ($formatted -join '、')
}

function Add-Clause {
    param([System.Collections.Generic.List[object]]$Map, [string]$Id, [string[]]$Paths, [string]$Effect)
    [void]$Map.Add([pscustomobject]@{ clause_id = $Id; decision_paths = $Paths; acceptance_effect = $Effect })
}

function New-ModuleText {
    param([string]$Heading, [string[]]$Lines)
    return "【$Heading】`n" + ($Lines -join "`n")
}

if (-not (Test-Path -LiteralPath $FixturePath -PathType Leaf)) { throw "Fixture not found: $FixturePath" }
$fixture = Get-Content -LiteralPath $FixturePath -Raw -Encoding UTF8 | ConvertFrom-Json
if (-not $fixture.fixture_only) { throw 'Only fixture-only input is accepted; this compiler never calls an image provider.' }

$compiled = @()
foreach ($case in (As-Array $fixture.cases)) {
    $failures = [System.Collections.Generic.List[string]]::new()
    $spec = $case.image_prompt_spec
    $assetType = [string](Get-Value $spec 'asset_type')
    $variant = [string](Get-Value $spec 'prompt_variant')
    $isVoxPilot = [bool](Get-Value $spec 'is_vox_pilot')
    $pilotDesignRoute = [string](Get-Value $spec 'pilot_design_route')
    $voxDesignRole = [string](Get-Value $spec 'vox_design_role')
    if ($assetType -notin @('character_identity', 'scene', 'prop', 'graphic', 'keyframe')) { Add-Failure $failures 'prompt_under_specified' }
    if ($variant -notin @('default', 'story_prop', 'product_evidence', 'cover_visual')) { Add-Failure $failures 'prompt_under_specified' }
    if ($variant -eq 'product_evidence' -and $assetType -ne 'prop') { Add-Failure $failures 'prompt_under_specified' }
    if ($variant -eq 'cover_visual' -and $assetType -ne 'keyframe') { Add-Failure $failures 'prompt_under_specified' }
    if ($isVoxPilot -and $pilotDesignRoute -notin @('hero_key_art', 'production_reconstructable')) { Add-Failure $failures 'prompt_under_specified' }
    if (-not $isVoxPilot -and (Has-Text $pilotDesignRoute)) { Add-Failure $failures 'prompt_under_specified' }
    if (Has-Text $voxDesignRole) {
        if (-not $isVoxPilot -or $pilotDesignRoute -ne 'production_reconstructable' -or
            $voxDesignRole -notin @('base_scene', 'transparent_overlay') -or
            -not (Has-Text (Get-Value $spec 'layout_intent'))) { Add-Failure $failures 'prompt_under_specified' }
        if ($voxDesignRole -eq 'transparent_overlay' -and
            (-not (Has-Text (Get-Value $spec 'base_asset_ref')) -or
             [string](Get-Value (Get-Value $spec 'output_spec') 'background') -ne 'transparent')) {
            Add-Failure $failures 'prompt_under_specified'
        }
    }

    $decisions = Get-Value $spec 'decisions'
    $decisionNames = @('subject_action', 'context', 'composition_camera', 'lighting_outcome', 'style_aesthetic', 'optics')
    foreach ($name in $decisionNames) { Test-Decision (Get-Value $decisions $name) "decisions.$name" $failures }
    $color = Get-Value $decisions 'color'
    $colorStatus = [string](Get-Value $color 'status')
    if ($colorStatus -notin @('explicit', 'inherited', 'not_applicable')) { Add-Failure $failures 'prompt_under_specified' }
    if ($colorStatus -eq 'explicit' -and -not ((Has-Text (Get-Value $color 'identity_palette')) -or (Has-Text (Get-Value $color 'product_true_color')) -or (Has-Text (Get-Value $color 'grade')))) { Add-Failure $failures 'prompt_under_specified' }
    if ($colorStatus -eq 'inherited' -and -not (Has-Text (Get-Value $color 'inherited_from'))) { Add-Failure $failures 'prompt_under_specified' }
    if ($colorStatus -eq 'not_applicable' -and -not (Has-Text (Get-Value $color 'reason'))) { Add-Failure $failures 'prompt_under_specified' }
    foreach ($name in @('material_texture', 'text_handling')) { Test-Decision (Get-Value $spec $name) $name $failures }

    $context = Get-Value $decisions 'context'
    if ([string](Get-Value $context 'status') -eq 'explicit' -and -not ((Get-DecisionText $context) -in @('transparent', 'solid_color', 'neutral_studio', 'inherit_reference') -or (Has-Text (Get-DecisionText $context)))) { Add-Failure $failures 'prompt_under_specified' }
    $optics = Get-Value $decisions 'optics'
    $hardOptics = $variant -eq 'product_evidence' -or [bool](Get-Value $spec 'perspective_sensitive') -or [string](Get-Value $spec 'render_mode') -eq 'photorealistic'
    if ($hardOptics -and [string](Get-Value $optics 'status') -eq 'not_applicable') { Add-Failure $failures 'prompt_under_specified' }

    $identityColor = [string](Get-Value $color 'identity_palette')
    $productColor = [string](Get-Value $color 'product_true_color')
    $grade = [string](Get-Value $color 'grade')
    if ($grade -match '改变真实色|覆盖真实色|改写身份色') { Add-Failure $failures 'consistency_lock_violation' }

    $locks = Join-Values (Get-Value $spec 'consistency_locks')
    $variation = Join-Values (Get-Value $spec 'allowed_variation')
    $negatives = Join-Values (Get-Value $spec 'negative_constraints')
    if ($variant -eq 'product_evidence' -and (-not $locks -or -not $productColor)) { Add-Failure $failures 'consistency_lock_violation' }
    if ($locks -match 'Logo|logo' -and $negatives -match '无 Logo|删除 Logo|no logo') { Add-Failure $failures 'consistency_lock_violation' }
    if ($variation -match '键盘|端口|划痕|Logo|身份色' -and $locks -match '键盘|端口|划痕|Logo|身份色') { Add-Failure $failures 'consistency_lock_violation' }

    $output = Get-Value $spec 'output_spec'
    $background = [string](Get-Value $output 'background')
    $contextText = Get-DecisionText $context
    if ($background -eq 'transparent' -and $contextText -match '实拍|街道|室内|环境') { Add-Failure $failures 'output_spec_mismatch' }
    $unresolved = [System.Collections.Generic.List[string]]::new()
    foreach ($field in @('aspect_ratio', 'size', 'background', 'output_format')) {
        if (-not (Has-Text (Get-Value $output $field))) { [void]$unresolved.Add("output_spec.$field") }
    }
    if ($unresolved.Count -gt 0) { Add-Failure $failures 'output_spec_mismatch' }

    $coverContext = Get-Value $spec 'cover_context'
    if ($variant -eq 'cover_visual') {
        if ([string](Get-Value $coverContext 'platform') -notin @('xiaohongshu', 'douyin', 'youtube_shorts', 'youtube_long')) { Add-Failure $failures 'prompt_under_specified' }
        if (-not (Has-Text (Get-Value $coverContext 'platform_native_composition'))) { Add-Failure $failures 'prompt_under_specified' }
        if (-not (Has-Text (Get-Value $coverContext 'title_safe_zone'))) { Add-Failure $failures 'prompt_under_specified' }
        if (-not (Has-Text (Get-Value $coverContext 'thumbnail_priority'))) { Add-Failure $failures 'prompt_under_specified' }
        if ([bool](Get-Value $coverContext 'generate_text_in_image')) { Add-Failure $failures 'unintended_text_or_brand' }
        $coverReferences = As-Array (Get-Value $spec 'reference_bindings')
        if ($coverReferences.Count -eq 0) { Add-Failure $failures 'prompt_under_specified' }
        foreach ($reference in $coverReferences) {
            foreach ($field in @('asset_id', 'version', 'checksum_sha256', 'reference_role')) {
                if (-not (Has-Text (Get-Value $reference $field))) { Add-Failure $failures 'prompt_under_specified' }
            }
        }
    }

    # This is a local projection of already planned single-element assets, never a Manifest asset or provider request.
    $atlasInput = Get-Value $case 'atlas_prompt_projection'
    if ($null -ne $atlasInput) {
        $sourceAssetIds = As-Array (Get-Value $atlasInput 'source_asset_ids')
        $cells = As-Array (Get-Value $atlasInput 'cells')
        $grid = [string](Get-Value $atlasInput 'grid')
        $capacity = if ($grid -eq '2x2') { 4 } elseif ($grid -eq '3x3') { 9 } else { 0 }
        $expectedGrid = if ($sourceAssetIds.Count -le 4) { '2x2' } else { '3x3' }
        $allowedCellIds = if ($grid -eq '2x2') { @('A','B','C','D') } elseif ($grid -eq '3x3') { @('A','B','C','D','E','F','G','H','I') } else { @() }
        if ($capacity -eq 0 -or $grid -ne $expectedGrid) { Add-Failure $failures 'prompt_under_specified' }
        if ($sourceAssetIds.Count -lt 1 -or $sourceAssetIds.Count -gt $capacity -or @($sourceAssetIds | Select-Object -Unique).Count -ne $sourceAssetIds.Count) { Add-Failure $failures 'prompt_under_specified' }
        if ($cells.Count -ne $sourceAssetIds.Count -or $cells.Count -gt $capacity) { Add-Failure $failures 'prompt_under_specified' }
        $cellIds = @($cells | ForEach-Object { [string](Get-Value $_ 'cell_id') })
        if (@($cellIds | Where-Object { $_ -notin $allowedCellIds }).Count -gt 0 -or @($cellIds | Select-Object -Unique).Count -ne $cellIds.Count) { Add-Failure $failures 'prompt_under_specified' }
        foreach ($cell in $cells) {
            foreach ($field in @('element_name_zh', 'state_or_pose', 'asset_constraints', 'suggested_filename')) {
                if (-not (Has-Text (Get-Value $cell $field))) { Add-Failure $failures 'prompt_under_specified' }
            }
        }
        if (-not (Has-Text (Get-Value $atlasInput 'destination_background'))) { Add-Failure $failures 'prompt_under_specified' }
        $atlasBackground = Get-Value $atlasInput 'background'
        if ([string](Get-Value $atlasBackground 'type') -ne 'transparent') { Add-Failure $failures 'output_spec_mismatch' }
        $layout = Get-Value $atlasInput 'layout_constraints'
        foreach ($field in @('one_complete_subject_per_cell', 'wide_gutter', 'full_subject_inside_safe_area', 'no_in_image_labels', 'no_grid_lines', 'no_checkerboard', 'no_complex_scene')) {
            if (-not [bool](Get-Value $layout $field)) { Add-Failure $failures 'prompt_under_specified' }
        }
    }

    $script:map = [System.Collections.Generic.List[object]]::new()
    $subject = Get-DecisionText (Get-Value $decisions 'subject_action')
    $composition = Get-DecisionText (Get-Value $decisions 'composition_camera')
    $lighting = Get-DecisionText (Get-Value $decisions 'lighting_outcome')
    $style = Get-DecisionText (Get-Value $decisions 'style_aesthetic')
    $opticsText = Get-DecisionText $optics
    $material = Get-DecisionText (Get-Value $spec 'material_texture')
    $textHandling = Get-DecisionText (Get-Value $spec 'text_handling')
    $colorText = if ($productColor) { "真实颜色：$productColor；调色：$grade" } elseif ($identityColor) { "身份配色：$identityColor；调色：$grade" } else { "颜色与调色：$grade" }
    $modules = [System.Collections.Generic.List[string]]::new()
    $script:clauseId = 0
    function Add-LineClause {
        param([string]$Line, [string[]]$Paths, [string]$Effect)
        $script:clauseId += 1
        Add-Clause $script:map ("clause-{0:D2}" -f $script:clauseId) $Paths $Effect
        return $Line
    }

    switch ($assetType) {
        'character_identity' {
            [void]$modules.Add((New-ModuleText '主体' @((Add-LineClause $subject @('decisions.subject_action') 'defines identity task'))))
            [void]$modules.Add((New-ModuleText '设计' @((Add-LineClause ("来源锁定：$locks") @('source_locks','consistency_locks') 'preserves identity'))))
            [void]$modules.Add((New-ModuleText '视图材质' @((Add-LineClause ("$composition；背景：$contextText；$material") @('decisions.composition_camera','decisions.context','material_texture') 'controls view and materials'))))
            [void]$modules.Add((New-ModuleText '风格光线' @((Add-LineClause ("$style；$lighting" + $(if ($opticsText) { "；$opticsText" } else { '' })) @('decisions.style_aesthetic','decisions.lighting_outcome','decisions.optics') 'controls visible aesthetic'))))
            [void]$modules.Add((New-ModuleText '锁定约束' @((Add-LineClause "锁定项：$locks。" @('consistency_locks') 'prevents identity drift'), (Add-LineClause "允许变化：$variation。" @('allowed_variation') 'bounds variation'), (Add-LineClause "禁止项：$negatives。" @('negative_constraints') 'prevents named failures'))))
        }
        'scene' {
            [void]$modules.Add((New-ModuleText '场景' @((Add-LineClause "$subject；情境：$contextText。" @('decisions.subject_action','decisions.context') 'defines usable scene'))))
            [void]$modules.Add((New-ModuleText '空间' @((Add-LineClause "$composition。" @('decisions.composition_camera') 'controls spatial layout'))))
            [void]$modules.Add((New-ModuleText '构图光学' @((Add-LineClause $(if ($opticsText) { $opticsText } else { '无额外光学要求。' }) @('decisions.optics') 'controls optics only when applicable'))))
            [void]$modules.Add((New-ModuleText '材质光线' @((Add-LineClause "$material；$lighting。" @('material_texture','decisions.lighting_outcome') 'controls readable environment'))))
            [void]$modules.Add((New-ModuleText '风格色彩' @((Add-LineClause "$style；$colorText。" @('decisions.style_aesthetic','decisions.color') 'controls style without color drift'))))
            [void]$modules.Add((New-ModuleText '锁定约束' @((Add-LineClause "锁定项：$locks。" @('consistency_locks') 'preserves scene locks'), (Add-LineClause "允许变化：$variation。" @('allowed_variation') 'bounds variation'), (Add-LineClause "禁止项：$negatives。" @('negative_constraints') 'prevents named failures'))))
        }
        'prop' {
            if ($variant -eq 'product_evidence') {
                [void]$modules.Add((New-ModuleText '主体' @((Add-LineClause $subject @('decisions.subject_action') 'defines inspected product task'))))
                [void]$modules.Add((New-ModuleText '特征' @((Add-LineClause "来源锁定：$locks。" @('source_locks','consistency_locks') 'preserves inspected product evidence'))))
                [void]$modules.Add((New-ModuleText '场景构图' @((Add-LineClause "$contextText；$composition。" @('decisions.context','decisions.composition_camera') 'controls evidence composition'))))
                [void]$modules.Add((New-ModuleText '光学光线' @((Add-LineClause "$opticsText；$lighting。" @('decisions.optics','decisions.lighting_outcome') 'protects perspective and visible wear'))))
                [void]$modules.Add((New-ModuleText '材质色彩' @((Add-LineClause "$material；$colorText。" @('material_texture','decisions.color') 'preserves true color'))))
                [void]$modules.Add((New-ModuleText '锁定约束' @((Add-LineClause "锁定项：$locks。" @('consistency_locks') 'prevents product falsification'), (Add-LineClause "允许变化：$variation。" @('allowed_variation') 'bounds safe view changes'), (Add-LineClause "禁止项：$negatives。" @('negative_constraints') 'prevents unverified changes'))))
            } else {
                [void]$modules.Add((New-ModuleText '主体' @((Add-LineClause $subject @('decisions.subject_action') 'defines prop task'))))
                [void]$modules.Add((New-ModuleText '造型构图' @((Add-LineClause "$composition；背景：$contextText。" @('decisions.composition_camera','decisions.context') 'controls prop view'))))
                [void]$modules.Add((New-ModuleText '材质色彩' @((Add-LineClause "$material；$style；$colorText。" @('material_texture','decisions.style_aesthetic','decisions.color') 'controls appearance'))))
                [void]$modules.Add((New-ModuleText '锁定约束' @((Add-LineClause "锁定项：$locks。" @('consistency_locks') 'preserves locked prop facts'), (Add-LineClause "允许变化：$variation。" @('allowed_variation') 'bounds variation'), (Add-LineClause "禁止项：$negatives。" @('negative_constraints') 'prevents named failures'))))
            }
        }
        'graphic' {
            [void]$modules.Add((New-ModuleText '目标' @((Add-LineClause $subject @('decisions.subject_action') 'defines information outcome'))))
            [void]$modules.Add((New-ModuleText '版式' @((Add-LineClause "$composition；背景：$contextText。" @('decisions.composition_camera','decisions.context') 'controls layout and reserve area'))))
            [void]$modules.Add((New-ModuleText '风格色彩' @((Add-LineClause "$style；$colorText。" @('decisions.style_aesthetic','decisions.color') 'controls readable visual system'))))
            [void]$modules.Add((New-ModuleText '文字约束' @((Add-LineClause "$textHandling。" @('text_handling') 'routes exact text safely'), (Add-LineClause "锁定项：$locks。" @('consistency_locks') 'preserves graphic locks'), (Add-LineClause "允许变化：$variation。" @('allowed_variation') 'bounds variation'), (Add-LineClause "禁止项：$negatives。" @('negative_constraints') 'prevents text errors'))))
        }
        'keyframe' {
            [void]$modules.Add((New-ModuleText '画面' @((Add-LineClause $subject @('decisions.subject_action') 'defines current visible state'))))
            [void]$modules.Add((New-ModuleText '参考继承' @((Add-LineClause ("参考绑定：" + (Format-ReferenceBindings (Get-Value $spec 'reference_bindings')) + '。') @('reference_bindings') 'assigns inherited responsibilities'))))
            [void]$modules.Add((New-ModuleText '构图光学' @((Add-LineClause ("$composition" + $(if ($opticsText) { "；$opticsText" } else { '' }) + '。') @('decisions.composition_camera','decisions.optics') 'controls current camera state'))))
            if ($variant -eq 'cover_visual') {
                $platform = [string](Get-Value $coverContext 'platform')
                $native = [string](Get-Value $coverContext 'platform_native_composition')
                $titleSafe = [string](Get-Value $coverContext 'title_safe_zone')
                $avoidance = Join-Values (Get-Value $coverContext 'platform_ui_avoidance')
                $thumbnail = [string](Get-Value $coverContext 'thumbnail_priority')
                [void]$modules.Add((New-ModuleText '封面构图' @(
                    (Add-LineClause "目标平台：$platform；平台原生构图：$native。" @('cover_context.platform','cover_context.platform_native_composition') 'prevents mechanical crop'),
                    (Add-LineClause "标题留白区：$titleSafe；界面避让：$avoidance；缩略图优先：$thumbnail。" @('cover_context.title_safe_zone','cover_context.platform_ui_avoidance','cover_context.thumbnail_priority') 'protects title and subject'),
                    (Add-LineClause '只生成无文字底图；精确中文、系列标识、底板和边框均留给后期程序化叠加，禁止水印、测试徽标和模板残留。' @('cover_context.generate_text_in_image','text_handling','negative_constraints') 'prevents text and template residue')
                )))
            }
            [void]$modules.Add((New-ModuleText '光线色彩' @((Add-LineClause "$lighting；$style；$colorText。" @('decisions.lighting_outcome','decisions.style_aesthetic','decisions.color') 'preserves visible continuity'))))
            [void]$modules.Add((New-ModuleText '连续约束' @((Add-LineClause "锁定项：$locks。" @('consistency_locks') 'preserves continuity locks'), (Add-LineClause "允许变化：$variation。" @('allowed_variation') 'bounds new-frame variation'), (Add-LineClause "禁止项：$negatives。" @('negative_constraints') 'prevents continuity break'))))
        }
    }

    if ($pilotDesignRoute -eq 'production_reconstructable' -and $voxDesignRole -eq 'base_scene') {
        [void]$modules.Add((New-ModuleText 'VOX Base Scene' @(
            (Add-LineClause 'Create a clean coherent scene Base for the planned final poster. Respect the reading path, protected text region, separable groups and framing allowance; retain physical architecture and props. Do not bake later editorial titles, arrows, routes or frames into this Base. The final Poster will be locally composed from independently verified overlays.' @('pilot_design_route','vox_design_role','layout_intent') 'keeps the base reusable and prevents a generated final-composite redraw')
        )))
    }
    elseif ($pilotDesignRoute -eq 'production_reconstructable' -and $voxDesignRole -eq 'transparent_overlay') {
        [void]$modules.Add((New-ModuleText 'VOX Independent Overlay' @(
            (Add-LineClause 'Create only the named independent design overlay with genuine transparent Alpha, matching the bound Base scene, planned layout, material and effective display size. This is a candidate until text/path, Alpha, rights and design checks pass; do not redraw the complete Poster.' @('pilot_design_route','vox_design_role','base_asset_ref','layout_intent','output_spec') 'preserves independent editability and candidate status')
        )))
    }
    elseif ($pilotDesignRoute -eq 'production_reconstructable') {
        [void]$modules.Add((New-ModuleText 'VOX Pilot Route' @(
            (Add-LineClause 'Create one visually strong editorial poster that is intentionally reconstructable in layered motion design. The final composition must read as one coherent poster, while major typography groups, directional graphics, decorative ink/seal elements and context groups remain visually separable and independently reproducible.' @('pilot_design_route') 'requires coherent poster plus independently reconstructable visual groups'),
            (Add-LineClause 'Preserve useful negative space. Avoid large cross-element texture entanglement, continuous full-width scenery strips, visible crop boundaries, background halos, or designs that would require rectangular screenshot crops for reconstruction. Do not prescribe a fixed layer count, fixed layout, fixed palette, or project-specific visual constants.' @('pilot_design_route') 'prevents rectangle fallback and over-prescription')
        )))
    }

    $map = $script:map
    if ($map.Count -eq 0 -or @($map | Where-Object { $_.decision_paths.Count -eq 0 }).Count -gt 0) { Add-Failure $failures 'prompt_non_discriminating' }
    $prompt = $modules -join "`n`n"
    $status = if ($failures.Count -eq 0) { 'passed' } else { 'blocked' }
    $imageContractVersion = if ($variant -eq 'cover_visual') { '1.2' } else { '1.1' }
    $atlasProjection = $null
    if ($null -ne $atlasInput) {
        $atlasCells = @()
        foreach ($cell in (As-Array (Get-Value $atlasInput 'cells'))) {
            $atlasCells += [pscustomobject]@{ cell_id = Get-Value $cell 'cell_id'; element_name_zh = Get-Value $cell 'element_name_zh'; state_or_pose = Get-Value $cell 'state_or_pose'; asset_constraints = Get-Value $cell 'asset_constraints'; suggested_filename = Get-Value $cell 'suggested_filename' }
        }
        $atlasGrid = [string](Get-Value $atlasInput 'grid')
        $destinationBackground = [string](Get-Value $atlasInput 'destination_background')
        $atlasPrompt = "在当前 Work/Codex 任务对应的既有 ChatGPT Web 同一对话中生成一个 $atlasGrid 透明 PNG 素材图集：背景必须真正透明，宽 gutter，每格一个完整主体且四周安全留白；不生成文字、名称、标签、箭头、格线、棋盘格、复杂场景或跨格元素。预期最终合成背景：$destinationBackground。默认输出干净 Alpha 外形，不把新的剪纸轮廓或纸层投影永久烧进 PNG；轮廓将由 Remotion 按元素角色、目标背景与交付分辨率在运行时施加并在真实导出帧核验，投影保持独立。下载后先核验真实 Alpha，再使用 split-transparent-atlas.ps1 按名称本地裁切。" + (($atlasCells | ForEach-Object { " 格$($_.cell_id)：$($_.element_name_zh)，$($_.state_or_pose)；约束：$($_.asset_constraints)。" }) -join '')
        $atlasProjection = [pscustomobject]@{
            projection_type = 'manual_crop_from_named_transparent_atlas'; source_asset_ids = (As-Array (Get-Value $atlasInput 'source_asset_ids')); grid = $atlasGrid; cells = $atlasCells
            destination_background = $destinationBackground
            outline_policy = [pscustomobject]@{ owner = 'remotion_runtime_style'; bake_into_new_source_png = $false; goal = 'clear_continuous_cut_paper_separation'; selection_inputs = @('element_role','bound_background','delivery_resolution','edge_complexity'); global_width_constants = @(); shadow_separate = $true; validation = 'real_frame_at_bound_delivery_size_plus_human_review' }
            background = Get-Value $atlasInput 'background'; layout_constraints = Get-Value $atlasInput 'layout_constraints'
            handoff = [pscustomobject]@{ generation = 'chatgpt_web_existing_conversation'; crop = 'split-transparent-atlas.ps1_wrapper_to_python_named_row_major_true_alpha_only'; alpha_verification = 'required_before_crop_binding'; runtime_outline_validation = 'required_against_bound_destination_background_at_delivery_resolution'; remotion_input = 'individual_clean_alpha_rgba_png_only' }
            persistence = 'ephemeral_compiler_output_not_production_manifest_or_asset'
            call_package = [pscustomobject]@{ executable_prompt = $atlasPrompt; reference_bindings = (As-Array (Get-Value $spec 'reference_bindings')); request_parameters = [pscustomobject]@{ size = Get-Value $output 'size'; quality = Get-Value $output 'quality'; background = 'transparent'; output_format = Get-Value $output 'output_format' }; adapter_id = 'chatgpt_web'; unresolved_fields = @(); generation_status = 'blocked' }
        }
    }
    $compiled += [pscustomobject]@{
        case_id = $case.case_id
        expected_result = $case.expected_result
        image_prompt_spec = [pscustomobject]@{
            contract_version = $imageContractVersion; asset_id = $spec.asset_id; asset_type = $assetType; prompt_variant = $variant; is_vox_pilot = $isVoxPilot; pilot_design_route = if ($isVoxPilot) { $pilotDesignRoute } else { $null }; vox_design_role = if (Has-Text $voxDesignRole) { $voxDesignRole } else { $null }; source_locks = (As-Array (Get-Value $spec 'source_locks')); decisions = $decisions; material_texture = (Get-Value $spec 'material_texture'); text_handling = (Get-Value $spec 'text_handling'); consistency_locks = (As-Array (Get-Value $spec 'consistency_locks')); allowed_variation = (As-Array (Get-Value $spec 'allowed_variation')); reference_bindings = (As-Array (Get-Value $spec 'reference_bindings')); negative_constraints = (As-Array (Get-Value $spec 'negative_constraints')); output_spec = $output; cover_context = $coverContext; clause_decision_map = $map; executable_prompt = $prompt; qa = [pscustomobject]@{ status = $status; failures = $failures }
        }
        call_package = [pscustomobject]@{
            executable_prompt = $prompt; reference_bindings = (As-Array (Get-Value $spec 'reference_bindings')); request_parameters = [pscustomobject]@{ size = Get-Value $output 'size'; quality = Get-Value $output 'quality'; background = Get-Value $output 'background'; output_format = Get-Value $output 'output_format' }; adapter_id = 'local-fixture'; unresolved_fields = $unresolved; generation_status = if ($status -eq 'passed') { 'blocked' } else { 'blocked' }
        }
        atlas_prompt_projection = $atlasProjection
    }
}

$result = [pscustomobject]@{ fixture_only = $true; compiler = 'deterministic-image-prompt-fixture'; external_generation_called = $false; cases = $compiled }
$parent = Split-Path -Parent $OutputPath
if ($parent -and -not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
$result | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
Write-Output "PASS: Image Prompt Fixture compiled without external generation: $OutputPath"
