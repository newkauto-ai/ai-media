[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw "ASSERTION FAILED: $Message" }
}

function Get-TemplateModuleCount {
    param([string]$Path)
    return @((Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | Select-String -Pattern '【' -AllMatches).Matches).Count
}

$root = Split-Path -Parent $PSScriptRoot
$clipCompilerPolicy = Get-Content -Raw -LiteralPath (Join-Path $root 'video-production\modules\clip-prompt-compiler.md') -Encoding UTF8
$clipTemplatePolicy = Get-Content -Raw -LiteralPath (Join-Path $root 'video-production\templates\video-clip-prompt.md') -Encoding UTF8
$videoAdapterPolicy = Get-Content -Raw -LiteralPath (Join-Path $root 'video-production\adapters\video-adapter.md') -Encoding UTF8
$videoProductionSkill = Get-Content -Raw -LiteralPath (Join-Path $root 'video-production\SKILL.md') -Encoding UTF8
$lookDevPolicy = Get-Content -Raw -LiteralPath (Join-Path $root 'video-production\modules\lookdev-calibration.md') -Encoding UTF8
$lookDevSkillMirror = Get-Content -Raw -LiteralPath (Join-Path $root 'skills\video-production\modules\lookdev-calibration.md') -Encoding UTF8
Assert-True ($clipCompilerPolicy -match 'exact project page ID' -and $clipCompilerPolicy -match '已接受片段' -and $clipCompilerPolicy -match '正文另见') 'Notion projection must require exact project isolation and reject status/placeholder Video Prompt text.'
Assert-True ($clipTemplatePolicy -match 'copy-ready external prompt' -and $clipTemplatePolicy -match 'Clip Brief') 'Video Clip template must identify copy-ready output and reject placeholder prompts.'
Assert-True ($videoAdapterPolicy -match 'At project start' -and $videoAdapterPolicy -match 'provider or platform and access route' -and $videoAdapterPolicy -match 'target resolution') 'Video Adapter must capture execution-surface identity and output facts at project start.'
Assert-True ($lookDevPolicy -ceq $lookDevSkillMirror) 'LookDev calibration source and skills mirror must remain byte-for-byte identical.'
Assert-True ($lookDevPolicy -match 'uniform semantic-region interiors' -and $lookDevPolicy -match 'contour anti-alias coverage pixels') 'Local flat-color correction must separate interior flatness from anti-aliased contour coverage.'
Assert-True ($lookDevPolicy -match 'final-resolution indexed-palette or nearest-neighbor remap' -and $lookDevPolicy -match 'premultiplied-alpha area downsample') 'Local flat-color correction must reject jagged final-resolution remaps and require a coverage-preserving route.'
Assert-True ($lookDevPolicy -match 'thin curved anchor such as glasses' -and $lookDevPolicy -match 'remains pending human approval') 'LookDev QA must inspect a thin curved anchor and retain the human approval Gate.'
Assert-True ($videoAdapterPolicy -match 'prefer native locked dialogue' -and $videoAdapterPolicy -match 'approved per-character samples' -and $videoAdapterPolicy -match 'voice continuity') 'Native-audio policy must prefer low-post dialogue when supported and retain reference plus QA safeguards.'
Assert-True ($videoProductionSkill -match 'prioritizes less post-production' -and $clipCompilerPolicy -match 'failed audio routes to independent replacement') 'Video Production must not default supported native audio to silence or regenerate passing video for an isolated audio failure.'
Assert-True ($clipCompilerPolicy -match 'seedance_prompt_package' -and $clipCompilerPolicy -match 'timestamp_edit' -and $clipCompilerPolicy -match 'prompt_ready_for_external_use') 'Fast Path must compile a bounded external prompt package and preserve its non-generation terminal.'
$fixturePath = Join-Path $root 'tests\fixtures\audiovisual-director-xiyouji.fixture.json'
$currentFixturePath = Join-Path $root 'tests\fixtures\audiovisual-director-v1.2-minimal.fixture.json'
$compilerPath = Join-Path $root 'video-production\scripts\compile-production-fixture.ps1'
$tempDirectory = Join-Path ([System.IO.Path]::GetTempPath()) ('video-production-fixture-' + [guid]::NewGuid().ToString('N'))
$manifestPath = Join-Path $tempDirectory 'production_manifest.json'
$blockedManifestPath = Join-Path $tempDirectory 'production_manifest-domain-blocked.json'
$unresolvedManifestPath = Join-Path $tempDirectory 'production_manifest-output-unresolved.json'
$currentManifestPath = Join-Path $tempDirectory 'production_manifest-v1.2.json'

try {
    & $compilerPath -FixturePath $fixturePath -OutputPath $manifestPath -AspectRatio '9:16' -VideoResolution '1080x1920'
    $manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $production = $manifest.production_manifest

    Assert-True ($production.contract_version -eq '1.8') 'Production Manifest must use v1.8.'
    Assert-True ($production.prompt_policy.contract_version -eq '1.2' -and $production.prompt_policy.independent_request_policy -eq 'self_contained') 'Executable Prompt policy must require self-contained independent requests.'
    Assert-True ($production.prompt_policy.delivery_defaults.aspect_ratio -eq '9:16' -and $production.prompt_policy.delivery_defaults.video_resolution -eq '1080x1920') 'Prompt policy must retain resolved delivery parameters.'
    Assert-True (-not $production.audio_production.enabled -and $production.audio_production.status -eq 'disabled') 'Audio Production must remain opt-in by default.'
    Assert-True (-not $production.bgm_production.enabled -and $production.bgm_production.status -eq 'disabled') 'BGM Production must remain opt-in by default.'
    Assert-True ($production.semantic_locks.core_thesis -eq '能力未弱，责任边界扩大。') 'Frozen semantic lock changed.'
    Assert-True ($production.clips.Count -eq 10) 'Each of the 10 Fixture Beats should receive one initial Clip plan.'
    Assert-True (($production.clips | Measure-Object -Property duration_seconds -Sum).Sum -eq 78) 'Clip durations must sum to the fixture duration.'
    Assert-True (@($production.clips | Where-Object { $_.duration_seconds -lt 6 -or $_.duration_seconds -gt 14 }).Count -eq 0) 'Initial Clips must remain in the 6-14s range.'

    Assert-True ($production.lookdev.anchors.Count -ge 3 -and $production.lookdev.anchors.Count -le 5) 'LookDev must have 3-5 anchors.'
    Assert-True ($production.lookdev.anchors.Count -eq 4) 'Fixture LookDev anchor count must be preserved.'
    Assert-True ($production.generation_gate.state -eq 'awaiting_user_approval') 'No generation may proceed without the user cost Gate.'
    Assert-True (@($production.lookdev.anchors | Where-Object { $_.generated_image -ne $null -or $_.human_approval -ne $null }).Count -eq 0) 'Fixture must not claim generated images or human approval.'
    Assert-True ($production.input_provenance.adp_read_mode -eq 'read_only_compatibility') 'Legacy ADP v1.1 input must be marked read-only compatibility.'
    Assert-True (@($production.clips | Where-Object { $_.state_record_id -eq $null -or $_.video_prompt_spec.contract_version -ne '1.0' }).Count -eq 0) 'v1.7 Clips must reference ledger state and carry the feasibility spec.'
    Assert-True (@($production.continuity_ledger | Where-Object { $_.actual_end_state -ne $null -or $_.selected_generation -ne $null }).Count -eq 0) 'Fixture must not fabricate actual continuity or generation evidence.'

    & $compilerPath -FixturePath $currentFixturePath -OutputPath $currentManifestPath -AspectRatio '16:9' -VideoResolution '720p'
    $currentProduction = (Get-Content -LiteralPath $currentManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json).production_manifest
    Assert-True ($currentProduction.contract_version -eq '1.8' -and $currentProduction.input_provenance.adp_read_mode -eq 'current') 'Current ADP v1.2 input must compile to a new v1.8 revision.'
    Assert-True ($currentProduction.clips[0].clip_performance_binding.performance_plan_id -eq 'PP-FIXTURE-001') 'Current ADP v1.2 performance plan must remain a referenced Clip binding.'

    $templateExpectations = @{
        'character-identity-prompt.md' = 5
        'scene-production-prompt.md' = 6
        'prop-prompt.md' = 4
        'product-evidence-prompt.md' = 6
        'graphic-prompt.md' = 4
        'keyframe-prompt.md' = 5
        'video-clip-prompt.md' = 6
    }
    foreach ($name in $templateExpectations.Keys) {
        $count = Get-TemplateModuleCount -Path (Join-Path $root "video-production\templates\$name")
        Assert-True ($count -eq $templateExpectations[$name]) "Template $name must have $($templateExpectations[$name]) executable-prompt modules; found $count."
    }
    foreach ($name in @('character-identity-prompt.md', 'scene-production-prompt.md', 'prop-prompt.md', 'graphic-prompt.md', 'keyframe-prompt.md')) {
        $template = Get-Content -LiteralPath (Join-Path $root "video-production\templates\$name") -Raw -Encoding UTF8
        Assert-True ($template.Contains('锁定项：') -and $template.Contains('允许变化：') -and $template.Contains('禁止项：')) "Image template $name must expose locks, allowed variation, and prohibitions."
    }

    $identityCatalog = @{}
    foreach ($anchor in $production.prompt_policy.identity_invariants) { $identityCatalog[$anchor.anchor_id] = $anchor.text }
    Assert-True ($identityCatalog.Count -ge 3) 'Fixture must freeze the ADP character identities as reusable prompt anchors.'

    foreach ($clip in $production.clips) {
        $cursor = 0.0
        foreach ($segment in $clip.timeline) {
            Assert-True ([math]::Round([double]$segment.start_seconds, 1) -eq [math]::Round($cursor, 1)) "Timeline gap or overlap in $($clip.clip_id)."
            Assert-True ([double]$segment.end_seconds -gt [double]$segment.start_seconds) "Timeline segment must have positive duration in $($clip.clip_id)."
            $cursor = [double]$segment.end_seconds
        }
        Assert-True ([math]::Round($cursor, 1) -eq [math]::Round([double]$clip.duration_seconds, 1)) "Timeline does not end exactly at Clip duration in $($clip.clip_id)."
        Assert-True ([double]$clip.output_spec.duration_seconds -eq [double]$clip.duration_seconds) "Per-Clip output duration must equal timeline duration in $($clip.clip_id)."
        Assert-True ($clip.output_spec.aspect_ratio -eq '9:16' -and $clip.output_spec.resolution -eq '1080x1920' -and $clip.output_spec.status -eq 'resolved') "Per-Clip output parameters must be resolved in $($clip.clip_id)."
        Assert-True ($clip.prompt_layers.global_shared -ceq $production.prompt_policy.global_video_layer) "Global prompt layer must be copied exactly into $($clip.clip_id)."
        Assert-True ($clip.executable_video_prompt_preview.Contains($production.prompt_policy.global_video_layer)) "Executable prompt must carry the global layer in $($clip.clip_id)."
        foreach ($anchor in $clip.prompt_layers.identity_invariants) {
            Assert-True ($identityCatalog.ContainsKey($anchor.anchor_id)) "Unknown identity anchor $($anchor.anchor_id) in $($clip.clip_id)."
            Assert-True ($anchor.text -ceq $identityCatalog[$anchor.anchor_id]) "Identity anchor $($anchor.anchor_id) was paraphrased in $($clip.clip_id)."
            Assert-True ($clip.executable_video_prompt_preview.Contains($anchor.text)) "Executable prompt omitted identity anchor $($anchor.anchor_id) in $($clip.clip_id)."
        }
        $durationText = ([double]$clip.duration_seconds).ToString('0.0', [System.Globalization.CultureInfo]::InvariantCulture)
        Assert-True ($clip.executable_video_prompt_preview.Contains("时长 $durationText 秒")) "Executable prompt must state its own duration in $($clip.clip_id)."
        Assert-True ($clip.executable_video_prompt_preview.Contains('画幅 9:16') -and $clip.executable_video_prompt_preview.Contains('分辨率 1080x1920')) "Executable prompt must state aspect ratio and resolution in $($clip.clip_id)."
        Assert-True ($clip.executable_video_prompt_preview.Contains('不生成字幕') -and $clip.executable_video_prompt_preview.Contains('不生成背景音乐') -and $clip.executable_video_prompt_preview.Contains('水印')) "Separate-track prompts must carry the minimal global delivery negatives in $($clip.clip_id)."
        Assert-True ($clip.executable_video_prompt_preview -notmatch '(?i)BGM') "Video Clip Prompt must not include BGM in $($clip.clip_id)."
        Assert-True ($clip.actual_end_state -eq $null) "Fixture must not fabricate actual end state in $($clip.clip_id)."
    }

    $wukongAnchorVariants = @($production.clips | ForEach-Object { $_.prompt_layers.identity_invariants } | Where-Object { $_.anchor_id -eq 'char-wukong' } | Select-Object -ExpandProperty text -Unique)
    Assert-True ($wukongAnchorVariants.Count -eq 1) 'The same character anchor must remain byte-for-byte stable across independent Clips.'

    & $compilerPath -FixturePath $fixturePath -OutputPath $unresolvedManifestPath
    $unresolved = (Get-Content -LiteralPath $unresolvedManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json).production_manifest
    Assert-True (@($unresolved.clips | Where-Object { $_.output_spec.status -ne 'blocked_unresolved' -or $_.output_spec.aspect_ratio -ne $null -or $_.output_spec.resolution -ne $null }).Count -eq 0) 'Missing aspect ratio or resolution must remain explicit and block every Clip output spec.'
    Assert-True (@($unresolved.clips | Where-Object { -not $_.executable_video_prompt_preview.Contains('未配置（生成前必须补齐）') }).Count -eq 0) 'Unresolved output parameters must be visible in every reviewable prompt preview.'

    & $compilerPath -FixturePath $fixturePath -OutputPath $blockedManifestPath -BlockDomainId 'responsibility-reveal' -AspectRatio '9:16' -VideoResolution '1080x1920'
    $blocked = (Get-Content -LiteralPath $blockedManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json).production_manifest
    Assert-True ((@($blocked.clips | Where-Object { $_.domain_id -eq 'responsibility-reveal' -and $_.generation_status -eq 'blocked_by_domain' }).Count) -eq 2) 'Blocked Domain must block only its Clips.'
    Assert-True ((@($blocked.clips | Where-Object { $_.domain_id -eq 'journey-road' -and $_.generation_status -eq 'blocked_by_domain' }).Count) -eq 0) 'Blocked Domain must not block unrelated Domain Clips.'
    Assert-True ($blocked.qa.failure_taxonomy -contains 'domain_identity_failure') 'Failure taxonomy must include domain identity.'
    Assert-True ($blocked.qa.failure_taxonomy -contains 'prompt_under_specified' -and $blocked.qa.failure_taxonomy -contains 'prompt_non_discriminating' -and $blocked.qa.failure_taxonomy -contains 'consistency_lock_violation' -and $blocked.qa.failure_taxonomy -contains 'output_spec_mismatch' -and $blocked.qa.failure_taxonomy -contains 'unintended_text_or_brand') 'Failure taxonomy must include Executable Prompt QA failures.'

    Write-Output 'PASS: Skill 4 with Production Manifest v1.8 validates legacy ADP compatibility, self-contained video layers, per-Clip output specs, exact identity anchors, Clip planning, LookDev Gate, image-template registry, Audio and BGM opt-in boundaries, timelines, state references, feasibility fields, Domain isolation, continuity boundaries, failure taxonomy, and no-generation boundary.'
}
finally {
    if (Test-Path -LiteralPath $tempDirectory) { Remove-Item -LiteralPath $tempDirectory -Recurse -Force }
}
