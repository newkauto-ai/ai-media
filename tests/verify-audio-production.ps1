[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw "ASSERTION FAILED: $Message" }
}

$root = Split-Path -Parent $PSScriptRoot
$fixturePath = Join-Path $root 'tests\fixtures\audiovisual-director-xiyouji.fixture.json'
$compilerPath = Join-Path $root 'video-production\scripts\compile-production-fixture.ps1'
$voiceDatabasePath = Join-Path $root 'video-production\data\voice-types.json'
$tempDirectory = Join-Path ([System.IO.Path]::GetTempPath()) ('audio-production-fixture-' + [guid]::NewGuid().ToString('N'))
$manifestPath = Join-Path $tempDirectory 'production_manifest.audio.json'

try {
    & $compilerPath -FixturePath $fixturePath -OutputPath $manifestPath -EnableAudio
    $audio = ((Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json).production_manifest).audio_production

    Assert-True $audio.enabled 'Audio Production must be explicitly enabled for the audio fixture.'
    Assert-True ($audio.provider -eq 'doubao_tts') 'V1 fixture must use the Doubao provider binding.'
    Assert-True ($audio.status -eq 'awaiting_user_approval') 'Audio must stop at the explicit cost Gate.'
    Assert-True ($audio.voice_profiles.Count -eq 1 -and $audio.voice_profiles[0].voice_profile_id -eq 'narrator-main') 'Narration requires a reusable Voice Profile.'
    $voiceDatabase = Get-Content -LiteralPath $voiceDatabasePath -Raw -Encoding UTF8 | ConvertFrom-Json
    $selectedVoiceType = $audio.voice_profiles[0].provider_voice.voice_type
    Assert-True (@($voiceDatabase.voices | Where-Object { $_.provider -eq 'doubao_tts' -and $_.status -eq 'active' -and $_.voice_type -eq $selectedVoiceType }).Count -eq 1) 'The compiled Voice Profile must resolve its voice_type from the active Voice_Type database.'
    Assert-True ($audio.voice_profiles[0].selection.source -eq 'voice_type_database') 'Voice selection provenance must identify the Voice_Type database.'
    Assert-True ($audio.voice_requests.Count -eq 10) 'Every voice-bearing fixture Beat must yield one planned voice request.'
    Assert-True ($audio.audio_timeline.Count -eq $audio.voice_requests.Count) 'Each voice request must have exactly one timeline entry.'
    Assert-True (@($audio.voice_requests | Where-Object { $_.asset_path -ne $null -or $_.provider_request_id -ne $null -or $_.measured_duration_seconds -ne $null }).Count -eq 0) 'A local fixture must not fabricate generated audio evidence.'
    Assert-True (@($audio.audio_timeline | Where-Object { ([math]::Round([double]$_.planned_start_seconds, 1) -ne [double]$_.planned_start_seconds) -or ([math]::Round([double]$_.planned_end_seconds, 1) -ne [double]$_.planned_end_seconds) }).Count -eq 0) 'Audio Timeline must use one-decimal precision.'
    Assert-True (@($audio.voice_requests | Where-Object { $_.status -eq 'timing_conflict' }).Count -gt 0) 'The fixture must surface narration overflow instead of silently accelerating it.'
    Assert-True (($audio.deferred_tracks -join ',') -eq 'BGM,Foley,SFX') 'V1 must defer non-TTS audio tracks.'

    Write-Output 'PASS: Audio Production compiles reusable Voice_Type metadata and a planned timeline, preserves explicit approval, and detects timing conflicts.'
}
finally {
    if (Test-Path -LiteralPath $tempDirectory) { Remove-Item -LiteralPath $tempDirectory -Recurse -Force }
}
