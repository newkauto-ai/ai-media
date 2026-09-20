$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}

$projectRoot = Split-Path -Parent $PSScriptRoot
$pluginManifest = Get-Content -LiteralPath (Join-Path $projectRoot '.codex-plugin\plugin.json') -Raw -Encoding UTF8 | ConvertFrom-Json
Assert-True (-not [string]::IsNullOrWhiteSpace([string]$pluginManifest.skills)) 'Plugin manifest must declare a Skill entry.'
$declaredSkillsPath = ([string]$pluginManifest.skills).Replace('/', [System.IO.Path]::DirectorySeparatorChar)
$skillsRoot = [System.IO.Path]::GetFullPath((Join-Path $projectRoot $declaredSkillsPath))
Assert-True (Test-Path -LiteralPath $skillsRoot -PathType Container) "Manifest-declared Skill entry does not exist: $skillsRoot"
$libraryRoot = Join-Path $projectRoot 'style-profiles'
$sourceDir = Join-Path $libraryRoot 'source'
$normalizedDir = Join-Path $libraryRoot 'normalized'
$registryPath = Join-Path $libraryRoot 'registry.json'
$scannerPath = Join-Path $skillsRoot 'audiovisual-director\scripts\scan-style-profiles.ps1'

$registry = Get-Content -LiteralPath $registryPath -Raw | ConvertFrom-Json
Assert-True ($registry.profiles.Count -ge 2) 'Registry must retain at least the two original source-normalized profiles.'

$pastoralEntry = @($registry.profiles | Where-Object { $_.profile_id -eq 'oriental_pastoral_cinematic_lifestyle' })
Assert-True ($pastoralEntry.Count -eq 1) 'Pastoral cinematic lifestyle must resolve to one stable profile ID.'
Assert-True ($pastoralEntry[0].status -eq 'pending_review') 'New pastoral profile must remain pending_review until real LookDev acceptance.'
$pastoralProfile = Get-Content -LiteralPath (Join-Path $normalizedDir $pastoralEntry[0].normalized_file) -Raw | ConvertFrom-Json
Assert-True ($pastoralProfile.style_profile.display_name -eq '田园风') 'Pastoral profile must preserve the user-visible Chinese name.'
Assert-True ($pastoralProfile.style_profile.audiovisual_modules.visual_identity.value -match '真人') 'Pastoral profile must retain its live-action cinematic identity.'
Assert-True ($pastoralProfile.style_profile.production_modules.fixed_model_is_canon -eq $false) 'Pastoral profile must not lock a production model into Style Core.'
Assert-True ($pastoralEntry[0].normalized_version -eq 'v1.1-zh') 'Pastoral registry must route the stable ID to v1.1-zh.'
Assert-True ($pastoralEntry[0].source_file -eq 'Style_Profile_田园风_v1.1_中文解析.md') 'Pastoral registry must route to the v1.1 source profile.'
Assert-True ($pastoralProfile.style_profile.version -eq 'v1.1-zh') 'Pastoral normalized profile must declare v1.1-zh.'
Assert-True (Test-Path -LiteralPath (Join-Path $normalizedDir 'oriental_pastoral_cinematic_lifestyle.v1.0-zh.json')) 'Pastoral v1.0 normalized history must be retained.'
$pastoralPre = $pastoralProfile.style_profile.pre_content_modules
$pastoralAV = $pastoralProfile.style_profile.audiovisual_modules
$pastoralProduction = $pastoralProfile.style_profile.production_modules
Assert-True ($pastoralPre.cultural_fidelity.style_may_invent_facts -eq $false) 'Pastoral style must not invent cultural facts.'
Assert-True ($pastoralPre.cultural_fidelity.evidence_required_for -contains '工艺步骤') 'Pastoral cultural fidelity must require evidence for craft steps.'
Assert-True ((@($pastoralAV.visual_domains.values | Sort-Object) -join ',') -eq 'craft_process,folk_culture,food_tea,pastoral_lifestyle') 'Pastoral v1.1 must expose the four approved visual domains.'
Assert-True ($pastoralAV.cinematography.value -match '服从当前信息任务') 'Pastoral cinematography must be task-driven rather than fixed-lens.'
Assert-True ($pastoralAV.depth_of_field.value -match 'task-dependent') 'Pastoral depth of field must be task-dependent.'
Assert-True ($pastoralAV.performance.value -match 'joyful / serene / focused / reverent / communal') 'Pastoral performance must keep runtime emotion modes.'
Assert-True ($pastoralAV.shot_architecture.value -match '环境负责世界') 'Pastoral v1.1 must define functional shot architecture.'
Assert-True ($pastoralAV.shot_design.value -match 'one_primary_attention_target') 'Pastoral shots must retain one primary attention target.'
Assert-True ($pastoralAV.process_visualization.value -match 'material_response.*visible_state_change') 'Pastoral process visualization must show material response and visible state change.'
Assert-True ($pastoralAV.process_continuity.value -eq 'previous_result_equals_next_input') 'Pastoral process continuity must carry each result into the next input.'
Assert-True ($pastoralProduction.prompt_compilation.require_visual_domain -eq $true) 'Pastoral prompt compilation must require a visual domain.'
Assert-True ($pastoralProduction.prompt_compilation.require_material_response -eq 'when_applicable') 'Pastoral prompt compilation must require material response when applicable.'
Assert-True ($pastoralProduction.fixed_lens_is_canon -eq $false) 'Pastoral v1.1 must not freeze one lens choice.'
Assert-True ($pastoralProduction.fixed_depth_of_field_is_canon -eq $false) 'Pastoral v1.1 must not freeze one depth-of-field choice.'
Assert-True (($pastoralProfile.style_profile.provenance.source_documents | Where-Object version -eq 'v1.0-zh').Count -eq 1) 'Pastoral provenance must retain v1.0 history.'
Assert-True (($pastoralProfile.style_profile.provenance.source_documents | Where-Object version -eq 'v1.1-zh').Count -eq 1) 'Pastoral provenance must record the v1.1 production-derived upgrade.'

$dreamyGardenEntry = @($registry.profiles | Where-Object { $_.profile_id -eq 'dreamy_garden_poetic_healing' })
Assert-True ($dreamyGardenEntry.Count -eq 1) 'Dreamy garden poetic healing must resolve to one stable profile ID.'
Assert-True ($dreamyGardenEntry[0].status -eq 'pending_review') 'New dreamy garden profile must remain pending_review until real LookDev acceptance.'
Assert-True ($dreamyGardenEntry[0].normalized_version -eq 'v1.1-zh') 'Dreamy garden registry must route the stable ID to v1.1-zh.'
Assert-True ($dreamyGardenEntry[0].source_file -eq 'Style_Profile_梦幻园林诗意治愈风_v1.1_生产经验升级.md') 'Dreamy garden registry must route to the v1.1 source profile.'
$dreamyGardenProfile = Get-Content -LiteralPath (Join-Path $normalizedDir $dreamyGardenEntry[0].normalized_file) -Raw | ConvertFrom-Json
Assert-True ($dreamyGardenProfile.style_profile.display_name -eq '梦幻园林诗意治愈风') 'Dreamy garden profile must preserve the user-visible Chinese name.'
Assert-True ($dreamyGardenProfile.style_profile.version -eq 'v1.1-zh') 'Dreamy garden normalized profile must declare v1.1-zh.'
Assert-True ($dreamyGardenProfile.style_profile.audiovisual_modules.visual_identity.medium -contains '二维数字手绘') 'Dreamy garden profile must retain its illustrated medium and remain distinct from the live-action pastoral profile.'
Assert-True ($dreamyGardenProfile.style_profile.production_modules.model_adapter_reference.model_syntax_locked -eq $false) 'Dreamy garden profile must keep model syntax replaceable.'
$dreamyGardenAV = $dreamyGardenProfile.style_profile.audiovisual_modules
$dreamyGardenProduction = $dreamyGardenProfile.style_profile.production_modules
Assert-True ($null -ne $dreamyGardenAV.airiness_system) 'Dreamy garden v1.1 must define airiness_system.'
Assert-True ($dreamyGardenAV.airiness_system.avoid -contains 'global_milky_haze') 'Airiness system must prohibit global milky haze.'
Assert-True ($dreamyGardenAV.character_system.beauty_normalization -eq 'prohibited') 'Character system must prohibit beauty normalization.'
Assert-True ($dreamyGardenAV.character_system.canon_override -eq 'required_when_available') 'Character system must allow Source/Series Canon to override default morphology.'
Assert-True ($null -ne $dreamyGardenAV.fabric_drape_system) 'Dreamy garden v1.1 must define fabric_drape_system.'
Assert-True ($dreamyGardenAV.fabric_drape_system.prohibit -contains 'repeated_triangle_folds') 'Fabric drape system must reject repeated triangle folds.'
Assert-True ($dreamyGardenAV.location_identity_system.source_canon_first -eq $true) 'Location identity must prefer source canon.'
Assert-True (@($dreamyGardenAV.location_identity_system.required_signature_fields).Count -eq 5) 'Location identity must require five signature fields.'
Assert-True ($dreamyGardenAV.motif_budget.major_motifs_per_shot -eq '2-4') 'Motif budget must limit each shot to 2-4 major motifs.'
Assert-True ($dreamyGardenProduction.canonical_text_integrity.canonical_text -eq 'exact_match_required') 'Canonical text must require exact match.'
Assert-True ($dreamyGardenProduction.canonical_text_integrity.wrong_character_result -eq 'TEXT_FAIL') 'Any wrong canonical character must be TEXT_FAIL.'
Assert-True ($null -ne $dreamyGardenProduction.approved_frame_lock) 'Dreamy garden v1.1 must define approved_frame_lock.'
Assert-True ($dreamyGardenProduction.approved_frame_lock.priority[0] -eq 'crop_or_extract') 'Approved frame lock must prefer extraction before regeneration.'
Assert-True ($null -ne $dreamyGardenProduction.multi_panel_policy) 'Dreamy garden v1.1 must define multi_panel_policy.'
Assert-True ($dreamyGardenProduction.multi_panel_policy.final_asset_policy -contains 'preserve_style_fingerprint') 'Final panel extraction must preserve the style fingerprint.'
Assert-True ($dreamyGardenProduction.style_fingerprint.freeze_after_lookdev_acceptance -eq $true) 'Accepted LookDev must freeze the style fingerprint.'
$dreamyCases = @($dreamyGardenProduction.lookdev_regression_cases)
Assert-True ($dreamyCases.Count -eq 6) 'Dreamy garden v1.1 must define static LookDev regression cases A-F.'
Assert-True ((@($dreamyCases.case_id | Sort-Object) -join ',') -eq 'A,B,C,D,E,F') 'Dreamy garden regression cases must be exactly A-F.'
$caseA = @($dreamyCases | Where-Object case_id -eq 'A')[0]
$caseB = @($dreamyCases | Where-Object case_id -eq 'B')[0]
$caseC = @($dreamyCases | Where-Object case_id -eq 'C')[0]
$caseD = @($dreamyCases | Where-Object case_id -eq 'D')[0]
$caseE = @($dreamyCases | Where-Object case_id -eq 'E')[0]
$caseF = @($dreamyCases | Where-Object case_id -eq 'F')[0]
Assert-True ($caseA.pass_criteria -contains 'depth_falloff_visible') 'Case A must verify structural airiness through depth falloff.'
Assert-True ($caseB.pass_criteria -contains 'no_slender_beauty_normalization') 'Case B must verify Canon body-type differences without beauty normalization.'
Assert-True ($caseC.pass_criteria -contains 'gravity_and_contact_driven_folds') 'Case C must verify gravity/contact-driven fabric drape.'
Assert-True ($caseD.pass_criteria -contains 'five_signature_fields_present') 'Case D must verify five-field location identity.'
Assert-True ($caseE.pass_criteria -contains 'exact_match_or_TEXT_FAIL') 'Case E must fail incorrect canonical Chinese text.'
Assert-True ($caseF.pass_criteria -contains 'extraction_or_outpaint_before_regeneration') 'Case F must preserve approved panels before regeneration.'
$dreamyGardenSourceText = Get-Content -LiteralPath (Join-Path $sourceDir $dreamyGardenEntry[0].source_file) -Raw -Encoding UTF8
Assert-True ($dreamyGardenSourceText -notmatch '宝钗|黛玉|湘云|怡红院|蘅芜苑|潇湘馆|稻香村|红楼梦') 'Generic dreamy garden Style Core must not hard-code project-specific literary Canon.'

foreach ($entry in $registry.profiles) {
    $sourcePath = Join-Path $sourceDir $entry.source_file
    $normalizedPath = Join-Path $normalizedDir $entry.normalized_file
    Assert-True (Test-Path -LiteralPath $sourcePath) "Missing source file: $($entry.source_file)"
    Assert-True (Test-Path -LiteralPath $normalizedPath) "Missing normalized file: $($entry.normalized_file)"
    $actualHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $sourcePath).Hash
    Assert-True ($actualHash -eq $entry.source_sha256) "$($entry.source_file): source hash does not match registry."
    $normalized = Get-Content -LiteralPath $normalizedPath -Raw | ConvertFrom-Json
    Assert-True (-not $normalized.fixture_only) "$($entry.normalized_file): formal profile cannot remain fixture_only."
    Assert-True ($normalized.library_status -eq $entry.status) "$($entry.normalized_file): normalized status must match registry."
    Assert-True ($normalized.style_profile.style_id -eq $entry.profile_id) "$($entry.normalized_file): profile_id mismatch."
}

$scan = @((& $scannerPath | ConvertFrom-Json))
$sourceCount = @(Get-ChildItem -LiteralPath $sourceDir -File -Filter '*.md').Count
Assert-True ($scan.Count -eq $sourceCount) 'Scanner must return every current Markdown source document.'
foreach ($entry in $registry.profiles) {
    $item = @($scan | Where-Object { $_.source_file -eq $entry.source_file })
    Assert-True ($item.Count -eq 1) "$($entry.source_file): registered source missing from scanner output."
    Assert-True ($item[0].status -eq $entry.status) "$($entry.source_file): scanner status must match registry status."
}
foreach ($item in @($scan | Where-Object { $_.status -ne 'ready' })) {
    Assert-True ($item.status -in @('pending_normalization', 'source_changed', 'pending_review')) "$($item.source_file): unexpected discovery status $($item.status)."
}

$tempBase = [System.IO.Path]::GetTempPath()
$tempProject = Join-Path $tempBase ("codex-style-profile-test-" + [guid]::NewGuid().ToString('N'))
try {
    New-Item -ItemType Directory -Force -Path (Join-Path $tempProject 'style-profiles\source'),(Join-Path $tempProject 'style-profiles\normalized') | Out-Null
    Copy-Item -LiteralPath $registryPath -Destination (Join-Path $tempProject 'style-profiles\registry.json')
    Get-ChildItem -LiteralPath $sourceDir -File | Copy-Item -Destination (Join-Path $tempProject 'style-profiles\source')
    Get-ChildItem -LiteralPath $normalizedDir -File | Copy-Item -Destination (Join-Path $tempProject 'style-profiles\normalized')
    [System.IO.File]::WriteAllText((Join-Path $tempProject 'style-profiles\source\新风格测试.md'), "# 新风格测试`r`n", [System.Text.UTF8Encoding]::new($false))

    $pendingScan = @((& $scannerPath -ProjectRoot $tempProject | ConvertFrom-Json))
    $newItem = @($pendingScan | Where-Object { $_.source_file -eq '新风格测试.md' })
    Assert-True ($newItem.Count -eq 1) 'Scanner did not discover the manually added Markdown file.'
    Assert-True ($newItem[0].status -eq 'pending_normalization') 'New source must be pending_normalization, not silently promoted.'
}
finally {
    if (Test-Path -LiteralPath $tempProject) {
        $resolvedTemp = [System.IO.Path]::GetFullPath($tempBase)
        $resolvedTarget = [System.IO.Path]::GetFullPath($tempProject)
        Assert-True ($resolvedTarget.StartsWith($resolvedTemp, [System.StringComparison]::OrdinalIgnoreCase)) 'Refusing to remove a test directory outside the system temp directory.'
        Remove-Item -LiteralPath $resolvedTarget -Recurse -Force
    }
}

Write-Output 'PASS: Style Profile library sources, normalized profiles, registry hashes, staged statuses, and manual-source pending discovery are valid.'
