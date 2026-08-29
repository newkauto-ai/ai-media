[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$FixturePath,

    [Parameter(Mandatory = $true)]
    [string]$OutputPath,

    [string]$BlockDomainId,

    [string]$VoiceTypeDatabasePath,

    [string]$AspectRatio,

    [string]$VideoResolution,

    [ValidateSet('separate_tracks', 'native_speech', 'silent')]
    [string]$NativeAudioMode = 'separate_tracks',

    [switch]$EnableAudio,

    [switch]$EnableBgm,

    [string]$BgmAssetRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Format-Seconds {
    param([double]$Value)
    return $Value.ToString('0.0', [System.Globalization.CultureInfo]::InvariantCulture)
}

function Get-TextSha256 {
    param([string]$Text)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
        return ([System.BitConverter]::ToString($sha.ComputeHash($bytes))).Replace('-', '').ToLowerInvariant()
    }
    finally { $sha.Dispose() }
}

function Get-VideoPrompt {
    param(
        [string]$ClipId,
        [double]$DurationSeconds,
        [string]$AspectRatio,
        [string]$Resolution,
        [string]$NativeAudioMode,
        [string]$GlobalLayer,
        [object[]]$IdentityInvariantLayers,
        [string]$StartState,
        [string]$EndState,
        [object[]]$Timeline,
        [string]$Performance,
        [string]$LightingAndColor,
        [string]$NativeSpeechText
    )

    $timelineText = ($Timeline | ForEach-Object {
        "$(Format-Seconds $_.start_seconds)–$(Format-Seconds $_.end_seconds)s：$($_.action)；$($_.camera)；$($_.state_change)"
    }) -join [Environment]::NewLine

    $aspectRatioText = if ([string]::IsNullOrWhiteSpace($AspectRatio)) { '未配置（生成前必须补齐）' } else { $AspectRatio }
    $resolutionText = if ([string]::IsNullOrWhiteSpace($Resolution)) { '未配置（生成前必须补齐）' } else { $Resolution }
    $nativeAudioText = switch ($NativeAudioMode) {
        'native_speech' { '模型原生语音，只使用本镜冻结原文' }
        'silent' { '静音，不生成任何声音' }
        default { '关闭，对白、旁白与其他声音走独立音轨' }
    }
    $identityText = if (@($IdentityInvariantLayers).Count -eq 0) {
        '无本镜人设锚点。'
    }
    else {
        (@($IdentityInvariantLayers) | ForEach-Object { "$($_.anchor_id)：$($_.text)" }) -join [Environment]::NewLine
    }
    $nativeSpeechLine = if ($NativeAudioMode -eq 'native_speech' -and -not [string]::IsNullOrWhiteSpace($NativeSpeechText)) {
        "`n原生语音原文（不得改写）：$NativeSpeechText"
    }
    else { '' }

    return @"
【规格与参考】
$ClipId；输出参数：时长 $(Format-Seconds $DurationSeconds) 秒；画幅 $aspectRatioText；分辨率 $resolutionText；原生音频 $nativeAudioText。
全局共享层（本次调用自包含）：$GlobalLayer
人设不变量层（冻结锚点原样复制）：
$identityText
参考状态：Clip-first Fixture 预览；待 LookDev Baseline 与成本 Gate 批准。

【起始状态】
$StartState

【时间轴】
$timelineText

【镜头与表演】
$Performance；$LightingAndColor；Shot 与 Camera Beat 分离。$nativeSpeechLine

【结束状态】
$EndState

【连续性与禁止项】
锁定项：继承已检验的实际结束状态与上述冻结锚点。
允许变化：仅限本镜时间轴、镜头、动作、微表情与明确状态变化。
禁止项：不改写冻结锚点，不新增未批准角色，不复刻既有影视造型。
"@
}

function Get-PropertyValue {
    param([object]$Object, [string]$Name)
    if ($null -eq $Object) { return $null }
    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property) { return $null }
    return $property.Value
}

function Get-IdentityInvariantText {
    param([object]$Character)

    $visualLabels = [ordered]@{
        apparent_age = '年龄/物种'
        body = '体型'
        face = '面部'
        hair = '头发/毛发'
        costume = '服装'
        palette = '配色'
        materials = '材质'
        accessories = '配件'
        silhouette = '轮廓'
        design_level = '呈现级别'
    }
    $visualParts = foreach ($entry in $visualLabels.GetEnumerator()) {
        $value = Get-PropertyValue -Object $Character.visual -Name $entry.Key
        if (-not [string]::IsNullOrWhiteSpace([string]$value)) { "$($entry.Value)：$value" }
    }
    $performanceLabels = [ordered]@{
        posture = '姿态'
        gesture_style = '动作基线'
        facial_behavior = '表情基线'
        motion_energy = '表演强度'
    }
    $performanceParts = foreach ($entry in $performanceLabels.GetEnumerator()) {
        $value = Get-PropertyValue -Object $Character.performance -Name $entry.Key
        if (-not [string]::IsNullOrWhiteSpace([string]$value)) { "$($entry.Value)：$value" }
    }
    $prohibited = @(Get-PropertyValue -Object $Character.visual -Name 'prohibited_changes')
    $prohibitedText = if ($prohibited.Count -gt 0) { $prohibited -join '、' } else { '无额外项' }

    return "$($Character.name)；视觉锁定：$($visualParts -join '；')。表演基线：$($performanceParts -join '；')。禁止变化：$prohibitedText。"
}

function Get-EstimatedSpeechDurationSeconds {
    param(
        [string]$Text,
        [double]$SpeechRate = 1.0
    )

    $units = @($Text.ToCharArray() | Where-Object { -not [char]::IsWhiteSpace($_) -and $_ -notin @('，', '、', '；', '：', '。', '？', '！', '…') }).Count
    $punctuationSeconds = 0.0
    foreach ($char in $Text.ToCharArray()) {
        if ($char -in @('，', '、')) { $punctuationSeconds += 0.18 }
        elseif ($char -in @('；', '：')) { $punctuationSeconds += 0.25 }
        elseif ($char -in @('。', '？', '！')) { $punctuationSeconds += 0.35 }
        elseif ($char -eq '…') { $punctuationSeconds += 0.50 }
    }
    return [math]::Round(($units / (4.2 * $SpeechRate)) + $punctuationSeconds + 0.15, 1)
}

if (-not (Test-Path -LiteralPath $FixturePath -PathType Leaf)) {
    throw "Fixture not found: $FixturePath"
}

$fixture = Get-Content -LiteralPath $FixturePath -Raw -Encoding UTF8 | ConvertFrom-Json
if (-not $fixture.fixture_only) { throw 'Only fixture-only input is accepted by this local compiler.' }
$VoiceTypeDatabasePath = if ([string]::IsNullOrWhiteSpace($VoiceTypeDatabasePath)) {
    Join-Path (Split-Path -Parent $PSScriptRoot) 'data\voice-types.json'
} else { $VoiceTypeDatabasePath }
if (-not (Test-Path -LiteralPath $VoiceTypeDatabasePath -PathType Leaf)) { throw "Voice_Type database not found: $VoiceTypeDatabasePath" }
$voiceTypeDatabase = Get-Content -LiteralPath $VoiceTypeDatabasePath -Raw -Encoding UTF8 | ConvertFrom-Json
$activeVoiceTypes = @($voiceTypeDatabase.voices | Where-Object { $_.provider -eq 'doubao_tts' -and $_.status -eq 'active' })
if ($activeVoiceTypes.Count -eq 0) { throw 'Voice_Type database has no active Doubao voice.' }
$selectedVoice = $activeVoiceTypes | Sort-Object @{ Expression = { if ($null -ne $_.recommendation.priority) { [int]$_.recommendation.priority } else { 0 } }; Descending = $true }, voice_id | Select-Object -First 1
if ($null -eq $selectedVoice) { throw 'Voice_Type database recommendation returned no active voice.' }
$adp = $fixture.audiovisual_direction_package
if ($adp.contract_version -notin @('1.1', '1.2')) { throw 'ADP contract_version 1.1 (read-only compatibility) or 1.2 is required.' }
if ($null -eq $adp.semantic_locks -or $null -eq $adp.style_blueprint.global_visual_dna -or $null -eq $adp.production_handoff.lookdev_test_spec) {
    throw 'ADP is missing a required Skill 4 v1.1 contract field.'
}
$legacyAdpInput = $adp.contract_version -eq '1.1'
$performancePlans = if ($legacyAdpInput) { @() } else { @($adp.performance_plans) }

$outputSpecStatus = if (-not [string]::IsNullOrWhiteSpace($AspectRatio) -and -not [string]::IsNullOrWhiteSpace($VideoResolution)) { 'resolved' } else { 'blocked_unresolved' }
$audioRoutingText = switch ($NativeAudioMode) {
    'native_speech' { '不生成字幕；不生成屏幕文字；不生成水印；不生成背景音乐；只按本镜冻结原文生成语音。' }
    'silent' { '不生成字幕；不生成屏幕文字；不生成水印；不生成背景音乐；不生成任何其他声音。' }
    default { '不生成字幕；不生成屏幕文字；不生成水印；不生成背景音乐；旁白、对白、环境声、拟音与特效音走独立音轨。' }
}
$globalDna = $adp.style_blueprint.global_visual_dna
$globalVideoLayer = "视觉基线：$($globalDna.line)；$($globalDna.world_motion)；空间规则：$($globalDna.spatial_rule)；原创性：$($globalDna.originality_rule)。交付约束：$audioRoutingText"
$identityInvariantCatalog = @($adp.character_voice_bible | ForEach-Object {
    [pscustomobject]@{
        anchor_id = $_.character_id
        text = Get-IdentityInvariantText -Character $_
        includes_voice = $false
        provenance = 'adp.character_voice_bible'
    }
})

$durations = @(7.0, 7.0, 8.0, 7.0, 8.0, 7.0, 8.0, 9.0, 10.0, 7.0)
$clipPlans = @()
$scenePlans = @(
    [pscustomobject]@{ scene_id = 'S01'; domain_id = 'celestial-memory'; beat_ids = @('B01', 'B02'); reason = '回忆域、单人行动与冷白光场连续' },
    [pscustomobject]@{ scene_id = 'S02'; domain_id = 'journey-road'; beat_ids = @('B03', 'B04', 'B05', 'B06', 'B07', 'B08'); reason = '同一山路、团队责任与自然侧光连续' },
    [pscustomobject]@{ scene_id = 'S03'; domain_id = 'responsibility-reveal'; beat_ids = @('B09', 'B10'); reason = '同一路径的责任揭示与暖光收束连续' }
)

for ($index = 0; $index -lt $adp.audiovisual_beats.Count; $index++) {
    $beat = $adp.audiovisual_beats[$index]
    $duration = [double]$durations[$index]
    $midpoint = [math]::Round($duration / 2.0, 1)
    $domainId = if ($beat.beat_id -in @('B01', 'B02')) { 'celestial-memory' } elseif ($beat.beat_id -in @('B09', 'B10')) { 'responsibility-reveal' } else { 'journey-road' }
    $pace = if ($beat.production.complexity -eq 'medium') { 'normal' } else { 'calm' }
    $shotCount = if ($beat.beat_id -in @('B01', 'B03', 'B09')) { 2 } else { 1 }
    $timeline = @(
        [pscustomobject]@{ start_seconds = 0.0; end_seconds = $midpoint; action = $beat.visual.action; camera = $beat.visual.camera; state_change = '建立动作与空间关系' },
        [pscustomobject]@{ start_seconds = $midpoint; end_seconds = $duration; action = '完成当前 Beat 的可见结果'; camera = '稳定收束到下一 Clip 可继承状态'; state_change = $beat.continuity.expected_end_state }
    )
    $priorState = if ($index -eq 0) { $beat.continuity.inherited_state } else { $adp.audiovisual_beats[$index - 1].continuity.expected_end_state }
    $clipIdentityLayers = @($beat.assets.character_ids | ForEach-Object {
        $characterId = $_
        $anchor = $identityInvariantCatalog | Where-Object { $_.anchor_id -eq $characterId } | Select-Object -First 1
        if ($null -eq $anchor) { throw "Missing frozen identity anchor '$characterId' for $($beat.beat_id)." }
        [pscustomobject]@{ anchor_id = $anchor.anchor_id; text = $anchor.text }
    })
    $performanceText = "表情：$($beat.performance.expression)；动作：$($beat.performance.gesture)；互动：$($beat.performance.interaction)"
    $lightingAndColor = "光线：$($beat.visual.lighting)；调色：$($beat.visual.color)"
    $outputSpec = [pscustomobject]@{
        duration_seconds = $duration
        aspect_ratio = if ([string]::IsNullOrWhiteSpace($AspectRatio)) { $null } else { $AspectRatio }
        resolution = if ([string]::IsNullOrWhiteSpace($VideoResolution)) { $null } else { $VideoResolution }
        native_audio_mode = $NativeAudioMode
        status = $outputSpecStatus
    }
    $stateRecordId = 'STATE-{0:D2}' -f ($index + 1)
    $performancePlan = $performancePlans | Where-Object { @($_.adp_beat_ids) -contains $beat.beat_id } | Select-Object -First 1
    $clipPerformanceBinding = if ($null -eq $performancePlan) {
        [pscustomobject]@{
            binding_id = "PB-$($beat.beat_id)"
            clip_id = ('C{0:D2}' -f ($index + 1))
            performance_plan_id = $null
            timeline_evidence = @()
            gate = [pscustomobject]@{ status = 'not_required'; evidence = @('No pivotal performance plan is attached to this Beat.'); failures = @() }
        }
    } else {
        [pscustomobject]@{
            binding_id = "PB-$($beat.beat_id)"
            clip_id = ('C{0:D2}' -f ($index + 1))
            performance_plan_id = $performancePlan.performance_plan_id
            timeline_evidence = @([pscustomobject]@{ start_seconds = 0.0; end_seconds = $duration; evidence_refs = @($performancePlan.performance_plan_id) })
            gate = [pscustomobject]@{ status = $performancePlan.gate.status; evidence = @($performancePlan.gate.evidence); failures = @($performancePlan.gate.failures) }
        }
    }
    $promptLayers = [pscustomobject]@{
        global_shared = $globalVideoLayer
        identity_invariants = $clipIdentityLayers
        clip_variables = [pscustomobject]@{
            start_state = $priorState
            timeline = $timeline
            performance = $performanceText
            lighting_and_color = $lightingAndColor
            native_speech_text = if ($NativeAudioMode -eq 'native_speech') { $beat.narration_or_dialogue } else { $null }
            intended_end_state = $beat.continuity.expected_end_state
        }
    }
    $continuityHandshake = [pscustomobject]@{
        predecessor_clip_id = if ($index -eq 0) { $null } else { 'C{0:D2}' -f $index }
        source_state_type = if ($index -eq 0) { 'first_clip' } else { 'frozen_planned_end_state' }
        state_record_id = if ($index -eq 0) { $null } else { 'STATE-{0:D2}' -f $index }
        source_reference = if ($index -eq 0) { $null } else { "continuity_ledger#STATE-{0:D2}" -f $index }
        scene_id = ($scenePlans | Where-Object { $_.beat_ids -contains $beat.beat_id }).scene_id
        scene_baseline_ids = @()
        camera_coverage_id = "COV-$($beat.beat_id)"
        status = if ($index -eq 0) { 'passed' } else { 'unknown' }
    }
    $videoPromptSpec = [pscustomobject]@{
        contract_version = '1.0'
        clip_id = ('C{0:D2}' -f ($index + 1))
        continuity_handshake = $continuityHandshake
        body_resource_timeline = @()
        spatial_relations = @()
        prop_state_transitions = @()
        physical_causality_assessments = @()
        literalization_scan = @([pscustomobject]@{ source_clause = $null; risk_type = $null; executable_rewrite = $null; source = 'human'; confidence = 'low'; status = 'unknown' })
        feasibility_gate = [pscustomobject]@{
            status = 'unknown'
            validator_results = @([pscustomobject]@{ check_id = 'fixture-open-semantics'; status = 'unknown'; validator_type = 'deterministic'; evidence = @('No free-text semantic inference in local Fixture compiler.'); confidence = 'low'; owner = 'video_production'; failures = @(); repair_targets = @() })
            failures = @()
            repair_targets = @()
        }
        executable_prompt = $null
    }
    $isBlockedDomain = -not [string]::IsNullOrWhiteSpace($BlockDomainId) -and $domainId -eq $BlockDomainId
    $clipPlans += [pscustomobject]@{
        clip_id = ('C{0:D2}' -f ($index + 1))
        scene_id = ($scenePlans | Where-Object { $_.beat_ids -contains $beat.beat_id }).scene_id
        domain_id = $domainId
        beat_ids = @($beat.beat_id)
        duration_seconds = $duration
        output_spec = $outputSpec
        prompt_layers = $promptLayers
        pace_profile = $pace
        shot_plan = @([pscustomobject]@{ shot_id = 'SH01'; purpose = $beat.story_function; cut_count = $shotCount; camera_beat_count = 2 })
        camera_beats = @([pscustomobject]@{ camera_beat_id = 'CB01'; phase = 'establish' }, [pscustomobject]@{ camera_beat_id = 'CB02'; phase = 'resolve' })
        timeline = $timeline
        state_record_id = $stateRecordId
        continuity_handshake = $continuityHandshake
        clip_performance_binding = $clipPerformanceBinding
        video_prompt_spec = $videoPromptSpec
        executable_video_prompt_preview = Get-VideoPrompt -ClipId ('C{0:D2}' -f ($index + 1)) -DurationSeconds $duration -AspectRatio $AspectRatio -Resolution $VideoResolution -NativeAudioMode $NativeAudioMode -GlobalLayer $globalVideoLayer -IdentityInvariantLayers $clipIdentityLayers -StartState $priorState -EndState $beat.continuity.expected_end_state -Timeline $timeline -Performance $performanceText -LightingAndColor $lightingAndColor -NativeSpeechText $beat.narration_or_dialogue
        expected_end_state = $beat.continuity.expected_end_state
        actual_end_state = $null
        generation_status = if ($isBlockedDomain) { 'blocked_by_domain' } else { 'blocked_by_lookdev_and_cost_gate' }
        block_reason = if ($isBlockedDomain) { "Domain '$BlockDomainId' is blocked." } elseif ($outputSpecStatus -ne 'resolved') { 'Output aspect ratio or video resolution is unresolved; no approved Visual Baseline or user-approved cost Gate.' } else { 'No approved Visual Baseline or user-approved cost Gate.' }
    }
}

$beatIdsForMapping = @($adp.audiovisual_beats | ForEach-Object { $_.beat_id })
$sceneManifestPlans = @($scenePlans | ForEach-Object {
    $scene = $_
    $sceneClipIds = @($scene.beat_ids | ForEach-Object {
        $beatIndex = [array]::IndexOf($beatIdsForMapping, $_)
        if ($beatIndex -ge 0) { 'C{0:D2}' -f ($beatIndex + 1) }
    })
    [pscustomobject]@{
        scene_id = $scene.scene_id
        domain_id = $scene.domain_id
        beat_ids = @($scene.beat_ids)
        clip_ids = $sceneClipIds
        planned_camera_coverage = @([pscustomobject]@{
            coverage_id = "COV-$($scene.scene_id)-PRIMARY"
            clip_ids = $sceneClipIds
            axis_group_id = "AXIS-$($scene.scene_id)-PRIMARY"
            view_direction = 'front'
            shot_size = 'wide'
            visible_zone_ids = @('foreground','action-zone','background')
            reveals_new_space = $false
            assessment = [pscustomobject]@{ source = 'structured_input'; evidence = @('Compatibility Fixture declares one axis group.'); confidence = 'high' }
        })
        scene_continuity_spec = [pscustomobject]@{
            contract_version = '1.0'
            scene_id = $scene.scene_id
            clip_ids = $sceneClipIds
            planned_camera_coverage = @()
            scene_setting_requirement = 'not_required'
            requirement_reason = 'Compatibility Fixture has no approved materially different coverage input.'
            coverage_bindings = @()
            gate = [pscustomobject]@{ status = 'not_required'; validator_type = 'deterministic'; evidence = @('No multi-angle trigger in compatibility input.'); confidence = 'high'; owner = 'video_production'; failures = @() }
        }
    }
})

$lookdevAnchors = @()
foreach ($anchor in $adp.production_handoff.lookdev_test_spec.anchors) {
    $anchorBlocked = -not [string]::IsNullOrWhiteSpace($BlockDomainId) -and $anchor.domain_id -eq $BlockDomainId
    $lookdevAnchors += [pscustomobject]@{
        anchor_id = $anchor.anchor_id
        type = $anchor.type
        subject = $anchor.subject
        domain_id = $anchor.domain_id
        executable_prompt_preview = "LookDev Fixture preview for $($anchor.subject). No external generation is authorized."
        status = if ($anchorBlocked) { 'domain_blocked' } else { 'awaiting_generation_and_human_approval' }
        generated_image = $null
        ai_qa = $null
        human_approval = $null
        visual_baseline_binding = $null
    }
}

$deferredAudioTracks = if ($EnableBgm) { @('Foley', 'SFX') } else { @('BGM', 'Foley', 'SFX') }
$audioProduction = if (-not $EnableAudio) {
    [pscustomobject]@{
        enabled = $false
        status = 'disabled'
        provider = $null
        asset_root = $null
        generation_gate = $null
        voice_profiles = @()
        voice_requests = @()
        audio_timeline = @()
        deferred_tracks = $deferredAudioTracks
    }
}
else {
    $voiceProfiles = @(
        [pscustomobject]@{
            voice_profile_id = 'narrator-main'
            scope = 'narration'
            speaker_id = 'NARRATOR'
            speaker_name = '旁白'
            source_voice_direction = $adp.style_blueprint.voice_identity.narration
            provider_voice = [pscustomobject]@{ provider = 'doubao_tts'; voice_type = $selectedVoice.voice_type; voice_id = $selectedVoice.voice_id; database_path = (Resolve-Path -LiteralPath $VoiceTypeDatabasePath).Path }
            delivery = [pscustomobject]@{ emotion = '克制、信息密度高'; speech_rate = 1.0; pause_style = '按标点自然短停顿'; emphasis = '关键结论轻重读' }
            prohibited_traits = @('煽情腔', '模仿真实人物')
            provenance = 'runtime_recommended'
            status = 'draft'
            revision = 1
            selection = [pscustomobject]@{ source = 'voice_type_database'; voice_id = $selectedVoice.voice_id; recommendation_rationale = $selectedVoice.recommendation.rationale }
        }
    )
    $voiceRequests = @()
    $audioTimeline = @()
    for ($index = 0; $index -lt $adp.audiovisual_beats.Count; $index++) {
        $beat = $adp.audiovisual_beats[$index]
        if ([string]::IsNullOrWhiteSpace($beat.narration_or_dialogue)) { continue }
        $clip = $clipPlans[$index]
        $profileId = $beat.audio.voice_profile_id
        $profile = $voiceProfiles | Where-Object { $_.voice_profile_id -eq $profileId }
        if ($null -eq $profile) { throw "Audio-enabled Fixture is missing Voice Profile '$profileId' for $($beat.beat_id)." }
        $estimate = Get-EstimatedSpeechDurationSeconds -Text $beat.narration_or_dialogue -SpeechRate ([double]$profile.delivery.speech_rate)
        $plannedStart = 0.0
        $plannedEnd = [math]::Round($plannedStart + $estimate, 1)
        $timingStatus = if ($plannedEnd -gt [double]$clip.duration_seconds) { 'timing_conflict' } else { 'planned' }
        $audioId = ('A-{0}-V1' -f $beat.beat_id)
        $request = [pscustomobject]@{
            audio_id = $audioId
            beat_id = $beat.beat_id
            scene_id = $clip.scene_id
            clip_id = $clip.clip_id
            text = $beat.narration_or_dialogue
            voice_profile_id = $profileId
            provider = 'doubao_tts'
            output_format = 'mp3'
            delivery = $profile.delivery
            estimated_duration_seconds = $estimate
            provider_request_id = $null
            asset_path = $null
            checksum_sha256 = $null
            measured_duration_seconds = $null
            qa = $null
            status = $timingStatus
        }
        $voiceRequests += $request
        $audioTimeline += [pscustomobject]@{
            audio_id = $audioId
            scene_id = $clip.scene_id
            clip_id = $clip.clip_id
            planned_start_seconds = $plannedStart
            planned_end_seconds = $plannedEnd
            speaker = $profile.speaker_name
            voice_profile_id = $profileId
            text = $beat.narration_or_dialogue
            estimated_duration_seconds = $estimate
            measured_duration_seconds = $null
            status = $timingStatus
        }
    }
    [pscustomobject]@{
        enabled = $true
        status = 'awaiting_user_approval'
        provider = 'doubao_tts'
        asset_root = $null
        generation_gate = [pscustomobject]@{
            state = 'awaiting_user_approval'
            minimum_generation_set = @($voiceRequests | ForEach-Object { $_.audio_id })
            estimated_cost = $null
            stopping_condition = 'Stop after the explicitly approved voice-request set; download and inspect each result before assembly.'
            approval_evidence = $null
        }
        voice_profiles = $voiceProfiles
        voice_requests = $voiceRequests
        audio_timeline = $audioTimeline
        deferred_tracks = $deferredAudioTracks
    }
}

$bgmProduction = if (-not $EnableBgm) {
    [pscustomobject]@{
        enabled = $false
        status = 'disabled'
        provider = $null
        model_id = $null
        output_format = $null
        asset_root = $null
        generation_gate = $null
        bgm_requests = @()
    }
}
else {
    if ($null -eq $adp.music -or [string]::IsNullOrWhiteSpace($adp.music.suno_prompt)) {
        throw 'BGM-enabled Fixture requires ADP music.music_brief and a non-empty music prompt.'
    }
    $musicBrief = $adp.music.music_brief
    $durationSeconds = if ($null -ne $musicBrief.PSObject.Properties['duration_seconds']) {
        [int]$musicBrief.duration_seconds
    }
    elseif ($null -ne $musicBrief.PSObject.Properties['duration']) {
        [int]$musicBrief.duration
    }
    else { throw 'BGM-enabled Fixture requires music_brief duration_seconds or duration.' }
    if ($durationSeconds -lt 3 -or $durationSeconds -gt 600) { throw "BGM duration $durationSeconds is outside the ElevenLabs Music range 3-600 seconds." }

    $prompt = [string]$adp.music.suno_prompt
    $promptSha256 = Get-TextSha256 $prompt
    $estimatedCredits = [math]::Ceiling(($durationSeconds / 60.0) * 900.0)
    $bgmId = 'BGM-MAIN-V1'
    $request = [pscustomobject]@{
        bgm_id = $bgmId
        provider = 'elevenlabs_music'
        model_id = 'music_v2'
        prompt_source = 'adp.music.suno_prompt'
        prompt = $prompt
        prompt_sha256 = $promptSha256
        music_length_ms = $durationSeconds * 1000
        force_instrumental = $true
        output_format = 'mp3_48000_192'
        estimated_credits = $estimatedCredits
        provider_song_id = $null
        provider_request_id = $null
        asset_path = $null
        checksum_sha256 = $null
        measured_duration_seconds = $null
        qa = $null
        status = 'awaiting_user_approval'
    }
    [pscustomobject]@{
        enabled = $true
        status = 'awaiting_user_approval'
        provider = 'elevenlabs_music'
        model_id = 'music_v2'
        output_format = 'mp3_48000_192'
        asset_root = if ([string]::IsNullOrWhiteSpace($BgmAssetRoot)) { $null } else { $BgmAssetRoot }
        pricing_basis = [pscustomobject]@{ approximate_credits_per_minute = 900; verified_date = '2026-08-24'; monetary_cost = 'unknown_plan_dependent' }
        generation_gate = [pscustomobject]@{
            state = 'awaiting_user_approval'
            minimum_generation_set = @($bgmId)
            model = 'music_v2'
            quantity = 1
            estimated_credits = $estimatedCredits
            estimated_monetary_cost = $null
            stopping_condition = 'Stop after one approved BGM request is downloaded and technically inspected; no retry, extension, mix, or assembly.'
            approval_evidence = $null
        }
        bgm_requests = @($request)
    }
}

$manifest = [pscustomobject]@{
    production_manifest = [pscustomobject]@{
        contract_version = '1.6'
        meta = [pscustomobject]@{ project_id = $adp.meta.project_id; script_id = $adp.meta.script_id; fixture_only = $true; generated_at = (Get-Date).ToUniversalTime().ToString('o'); revision = 'fixture-v1.6'; source_revision = if ($legacyAdpInput) { 'ADP-v1.1-read-only' } else { 'ADP-v1.2' } }
        semantic_locks = $adp.semantic_locks
        input_provenance = [pscustomobject]@{ adp_contract_version = $adp.contract_version; adp_read_mode = if ($legacyAdpInput) { 'read_only_compatibility' } else { 'current' }; style_profile_ids = @($adp.meta.selected_style_profiles); template_bindings = $adp.template_bindings; performance_provenance = 'story_change_arc -> performance_plan -> clip_performance_binding' }
        adapters = @(
            [pscustomobject]@{ adapter_id = 'local-fixture'; configured_models = $false; note = 'No external image, video, or voice generation call is configured.' },
            [pscustomobject]@{ adapter_id = 'elevenlabs-music-v2'; configured_models = $true; model_id = 'music_v2'; execution_mode = 'guarded_dry_run'; note = 'Live BGM generation still requires API credential and an exact user-approved cost Gate.' }
        )
        prompt_policy = [pscustomobject]@{
            contract_version = '1.2'
            independent_request_policy = 'self_contained'
            global_video_layer = $globalVideoLayer
            identity_invariants = $identityInvariantCatalog
            delivery_defaults = [pscustomobject]@{
                aspect_ratio = if ([string]::IsNullOrWhiteSpace($AspectRatio)) { $null } else { $AspectRatio }
                image_resolution = $null
                video_resolution = if ([string]::IsNullOrWhiteSpace($VideoResolution)) { $null } else { $VideoResolution }
                native_audio_mode = $NativeAudioMode
            }
        }
        generation_gate = [pscustomobject]@{ state = 'awaiting_user_approval'; minimum_generation_set = @($lookdevAnchors | ForEach-Object { $_.anchor_id }); model = $null; estimated_cost = $null; stopping_condition = 'Stop after the approved 3-5 anchor set; do not batch-generate.'; approval_evidence = $null }
        lookdev = [pscustomobject]@{ status = if ($BlockDomainId) { 'domain_blocked' } else { 'awaiting_generation' }; validation_dimensions = @($adp.production_handoff.lookdev_test_spec.validation_dimensions); anchors = $lookdevAnchors }
        visual_baselines = @()
        scenes = $sceneManifestPlans
        clips = $clipPlans
        assets = @()
        audio_production = $audioProduction
        bgm_production = $bgmProduction
        continuity_ledger = @($clipPlans | ForEach-Object { [pscustomobject]@{ state_record_id = $_.state_record_id; clip_id = $_.clip_id; expected_end_state = $_.expected_end_state; actual_start_state = $null; actual_end_state = $null; selected_generation = $null; usable = $null } })
        qa = [pscustomobject]@{ failure_taxonomy = @('prompt_under_specified', 'prompt_non_discriminating', 'consistency_lock_violation', 'output_spec_mismatch', 'unintended_text_or_brand', 'identity_drift', 'duplicate_or_extra_character', 'false_visual_leak', 'style_drift', 'domain_identity_failure', 'environment_drift', 'prop_drift', 'motion_failure', 'camera_failure', 'timing_failure', 'multishot_failure', 'expression_overacting', 'expression_underacting', 'continuity_mismatch', 'text_render_failure', 'artifact', 'continuity_source_missing', 'continuity_state_mismatch', 'scene_coverage_binding_missing', 'body_resource_conflict', 'posture_reach_conflict', 'prop_state_transition_invalid', 'physical_causality_violation', 'literalization_risk', 'internal_state_not_visualized', 'emotion_transition_missing', 'decision_signal_missing', 'performance_state_mismatch'); results = @(); retries = @() }
    }
}

$outputParent = Split-Path -Parent $OutputPath
if ($outputParent -and -not (Test-Path -LiteralPath $outputParent)) {
    New-Item -ItemType Directory -Force -Path $outputParent | Out-Null
}
$manifest | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
Write-Output "PASS: Fixture production manifest compiled without external generation: $OutputPath"
