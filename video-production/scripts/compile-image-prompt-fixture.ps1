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
    if ($assetType -notin @('character_identity', 'scene', 'prop', 'graphic', 'keyframe')) { Add-Failure $failures 'prompt_under_specified' }
    if ($variant -notin @('default', 'story_prop', 'product_evidence', 'cover_visual')) { Add-Failure $failures 'prompt_under_specified' }
    if ($variant -eq 'product_evidence' -and $assetType -ne 'prop') { Add-Failure $failures 'prompt_under_specified' }
    if ($variant -eq 'cover_visual' -and $assetType -ne 'keyframe') { Add-Failure $failures 'prompt_under_specified' }

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

    $map = $script:map
    if ($map.Count -eq 0 -or @($map | Where-Object { $_.decision_paths.Count -eq 0 }).Count -gt 0) { Add-Failure $failures 'prompt_non_discriminating' }
    $prompt = $modules -join "`n`n"
    $status = if ($failures.Count -eq 0) { 'passed' } else { 'blocked' }
    $imageContractVersion = if ($variant -eq 'cover_visual') { '1.2' } else { '1.1' }
    $compiled += [pscustomobject]@{
        case_id = $case.case_id
        expected_result = $case.expected_result
        image_prompt_spec = [pscustomobject]@{
            contract_version = $imageContractVersion; asset_id = $spec.asset_id; asset_type = $assetType; prompt_variant = $variant; source_locks = (As-Array (Get-Value $spec 'source_locks')); decisions = $decisions; material_texture = (Get-Value $spec 'material_texture'); text_handling = (Get-Value $spec 'text_handling'); consistency_locks = (As-Array (Get-Value $spec 'consistency_locks')); allowed_variation = (As-Array (Get-Value $spec 'allowed_variation')); reference_bindings = (As-Array (Get-Value $spec 'reference_bindings')); negative_constraints = (As-Array (Get-Value $spec 'negative_constraints')); output_spec = $output; cover_context = $coverContext; clause_decision_map = $map; executable_prompt = $prompt; qa = [pscustomobject]@{ status = $status; failures = $failures }
        }
        call_package = [pscustomobject]@{
            executable_prompt = $prompt; reference_bindings = (As-Array (Get-Value $spec 'reference_bindings')); request_parameters = [pscustomobject]@{ size = Get-Value $output 'size'; quality = Get-Value $output 'quality'; background = Get-Value $output 'background'; output_format = Get-Value $output 'output_format' }; adapter_id = 'local-fixture'; unresolved_fields = $unresolved; generation_status = if ($status -eq 'passed') { 'blocked' } else { 'blocked' }
        }
    }
}

$result = [pscustomobject]@{ fixture_only = $true; compiler = 'deterministic-image-prompt-fixture'; external_generation_called = $false; cases = $compiled }
$parent = Split-Path -Parent $OutputPath
if ($parent -and -not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
$result | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
Write-Output "PASS: Image Prompt Fixture compiled without external generation: $OutputPath"
