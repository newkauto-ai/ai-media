Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw "ASSERTION FAILED: $Message" }
}

function Get-Skill5Python {
    $bundled = Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
    if (Test-Path -LiteralPath $bundled) { return $bundled }
    $command = Get-Command python -ErrorAction SilentlyContinue
    if (-not $command) { throw 'Python runtime missing for local Skill 5 tests.' }
    return $command.Source
}

function New-Skill5TestVideo {
    param([string]$Path, [string]$Color = '0x4A6785', [int]$Width = 720, [int]$Height = 1280, [double]$Duration = 2)
    $ffmpeg = (Get-Command ffmpeg -ErrorAction Stop).Source
    & $ffmpeg -hide_banner -loglevel error -y -f lavfi -i "color=c=$Color`:s=$Width`x$Height`:d=$Duration" -c:v libx264 -pix_fmt yuv420p $Path
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $Path)) { throw 'Failed to build local non-generative test video.' }
}

function New-Skill5BaseInput {
    param(
        [string]$VideoPath,
        [string[]]$Platforms = @('youtube_shorts'),
        [string]$FinalQaStatus = 'accepted',
        [bool]$FixtureOnly = $true,
        [bool]$ShadowOnly = $false
    )
    $hash = (Get-FileHash -LiteralPath $VideoPath -Algorithm SHA256).Hash
    $size = (Get-Item -LiteralPath $VideoPath).Length
    return [ordered]@{
        schema_version = '1.2'
        project = @{ project_id = 'skill5-test'; content_id = 'content-001' }
        source_artifact = @{
            artifact_id = 'artifact-001'; artifact_version = 'v1'; path_or_uri = $VideoPath; checksum_sha256 = $hash
            file_size_bytes = $size; duration_seconds = 2; width = 720; height = 1280; aspect_ratio = '9:16'
            language = 'zh-CN'; final_qa_status = $FinalQaStatus; inspected_at = '2026-08-28T00:00:00+08:00'
        }
        upstream_refs = @{
            frozen_script_id = 'script-001'; frozen_script_hash = ('A' * 64)
            audiovisual_direction_id = 'adp-001'; audiovisual_direction_hash = ('B' * 64)
            production_manifest_id = 'manifest-001'; production_manifest_version = '1.6'; production_manifest_hash = ('C' * 64)
            upstream_review_result_ids = @('REVIEW-UPSTREAM-GATE1')
        }
        content_core = @{
            topic = '一条真实含义的本地测试内容'; core_promise = '说明封面包装如何保持来源和承诺一致'; audience = '内容创作者'
            audience_need = '减少发布前整理'; story_hook = '封面不是提示词，它必须是一份真实文件'; hook = '封面不是提示词，它必须是一份真实文件'
            platform_titles = @{}; approved_cover_titles = @{}; key_points = @('绑定成片', '绑定封面', '不自动发布')
            factual_claims = @(); search_intent = '发布包装'; share_save_reason = '保存检查清单'; content_type = 'video'; ai_generation_profile = @{}
        }
        series_context = @{
            series_id = 'series-test'; series_name = '包装验证'; packaging_visual_rules_ref = $null; packaging_visual_rules_version = $null
            source_status = 'missing'; approved_exceptions = @(); run_local_constraints = @{ series_mark = '包装验证'; brand_color = '#F6C445'; accent_color = '#FFFFFF'; font_rights_status = 'system' }
        }
        publishing_context = @{
            target_platforms = $Platforms; publish_goal = 'awareness'; requested_publish_date = '2026-08-29'; primary_audience_timezone = 'Asia/Singapore'
            historical_performance_refs = @(); account_profiles = @(
                @{ platform = 'youtube_shorts'; self_declared_made_for_kids = $false; locale = 'zh-CN' },
                @{ platform = 'youtube_long'; self_declared_made_for_kids = $false; locale = 'zh-CN' }
            )
        }
        platform_copy = @{
            youtube_shorts = @{ title = '封面不是提示词，它必须是一份真实文件'; description = '本地 Package-only 验证，不发布。'; hashtags = @('发布包装', '内容创作') }
            youtube_long = @{ title = '如何把成片编译为可核验的本地发布包'; description = '演示来源绑定、程序化封面和发布前检查。'; hashtags = @('发布包装', '内容创作') }
        }
        legacy_packaging = @{
            youtube_shorts = @{ title = 'Skill 2 旧标题'; description = 'legacy hint'; tags = @('legacy') }
        }
        cover_sources = @{ approved_keyframes = @(); supplied_assets = @(); generated_background_fallback = @{} }
        cover_inputs = @{ approved_assets = @(); approved_keyframes = @(); visual_thesis = '真实文件、校验和与平台原生构图'; required_subjects = @(); required_action = '清晰展示封面包装的本地验证画面'; forbidden_elements = @('watermark', 'test badge'); identity_locks = @(); style_locks = @(); platform_composition_overrides = @() }
        rights_and_disclosure = @{
            rights_provenance_refs = @('local:test-video-created-by-ffmpeg'); commercial_relationship = 'none'; ai_disclosure_required = $false
            disclosure_text = $null; platform_setting_action = $null; contains_synthetic_media = $false; has_paid_product_placement = $false
        }
        review_inputs = @{
            promise_match = 'pass'; metadata_relevance = 'pass'; evidence_refs = @('fixture:declared-projection')
            performance_assessment = @{ audience_match = 'strong'; discovery_match = 'mixed'; title_cover_synergy = 'strong'; series_consistency = 'strong'; qualified_click_hypothesis = 'mixed'; evidence = @('fixture qualitative projection') }
            evaluator_result = $null
        }
        execution_mode = @{ cover_prompt_only = $false; allow_real_generation = $false }
        runtime_context = @{ fixture_only = $FixtureOnly; shadow_only = $ShadowOnly; as_of = '2026-08-28T00:00:00+08:00' }
    }
}

function Invoke-Skill5Compile {
    param([object]$InputObject, [string]$TempRoot, [string]$ProjectRoot, [string]$Name = 'run')
    $inputPath = Join-Path $TempRoot "$Name.input.json"
    $outputPath = Join-Path $TempRoot "$Name.output"
    $InputObject | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath $inputPath -Encoding UTF8
    $python = Get-Skill5Python
    $runtime = Join-Path $ProjectRoot 'publishing-packaging\scripts\publishing_packaging_runtime.py'
    $profiles = Join-Path $ProjectRoot 'publishing-packaging\platform-profiles'
    & $python $runtime compile --input $inputPath --output $outputPath --profiles $profiles | Out-Null
    $exitCode = $LASTEXITCODE
    return [pscustomobject]@{ InputPath = $inputPath; OutputPath = $outputPath; ExitCode = $exitCode }
}
