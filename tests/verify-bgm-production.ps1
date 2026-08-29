[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw "ASSERTION FAILED: $Message" }
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

$root = Split-Path -Parent $PSScriptRoot
$fixturePath = Join-Path $root 'tests\fixtures\audiovisual-director-xiyouji.fixture.json'
$compilerPath = Join-Path $root 'video-production\scripts\compile-production-fixture.ps1'
$invokePath = Join-Path $root 'video-production\scripts\invoke-elevenlabs-music-v2.ps1'
$helperPath = Join-Path $root 'video-production\scripts\elevenlabs-music-v2-request.mjs'
$contractPath = Join-Path $root 'video-production\contracts\bgm-production-contract.md'
$adapterPath = Join-Path $root 'video-production\adapters\elevenlabs-music-v2-adapter.md'
$tempDirectory = Join-Path ([System.IO.Path]::GetTempPath()) ('bgm-production-fixture-' + [guid]::NewGuid().ToString('N'))
$manifestPath = Join-Path $tempDirectory 'production_manifest.bgm.json'
$outputPath = Join-Path $tempDirectory 'dry-run.mp3'
$prompt = 'Instrumental restrained cinematic score, low strings and bamboo flute, no vocals, no named artist imitation.'

try {
    & $compilerPath -FixturePath $fixturePath -OutputPath $manifestPath -EnableBgm -BgmAssetRoot (Join-Path $tempDirectory 'bgm')
    $production = (Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json).production_manifest
    $bgm = $production.bgm_production
    $request = $bgm.bgm_requests[0]

    Assert-True ($production.contract_version -eq '1.6') 'BGM fixture requires Production Manifest v1.6.'
    Assert-True ($bgm.enabled -and $bgm.status -eq 'awaiting_user_approval') 'BGM must stop at the explicit generation Gate.'
    Assert-True ($bgm.provider -eq 'elevenlabs_music' -and $bgm.model_id -eq 'music_v2') 'BGM must route to ElevenLabs Music v2.'
    Assert-True ($bgm.output_format -eq 'mp3_48000_192') 'Music v2 must use the declared MP3 output format.'
    Assert-True ($bgm.generation_gate.quantity -eq 1 -and $bgm.generation_gate.approval_evidence -eq $null) 'Fixture must plan exactly one unapproved request.'
    Assert-True ($request.force_instrumental -and $request.music_length_ms -eq 78000) 'Fixture must preserve duration and force instrumental output.'
    Assert-True ($request.prompt_sha256 -match '^[a-f0-9]{64}$') 'BGM prompt must have a stable SHA-256 approval binding.'
    Assert-True ($request.provider_song_id -eq $null -and $request.asset_path -eq $null -and $request.checksum_sha256 -eq $null) 'Fixture must not fabricate provider or asset evidence.'
    Assert-True (($production.audio_production.deferred_tracks -join ',') -eq 'Foley,SFX') 'Enabled BGM must no longer be mislabeled as a deferred voice-production track.'

    $dryRun = & $invokePath -OutputPath $outputPath -Prompt $prompt -DurationSeconds 30 2>&1 | Out-String
    Assert-True ($dryRun.Contains('DRY RUN') -and $dryRun.Contains('MODEL: music_v2')) 'Guarded provider script must default to dry-run.'
    Assert-True ($dryRun.Contains('ESTIMATED_CREDITS: 450')) 'Dry-run must expose the current credit estimate.'
    Assert-True ($dryRun.Contains((Get-TextSha256 $prompt))) 'Dry-run must expose the exact prompt hash for approval.'
    Assert-True (-not (Test-Path -LiteralPath $outputPath)) 'Dry-run must not create an audio file.'

    $missingGate = $null
    try { & $invokePath -OutputPath $outputPath -Prompt $prompt -DurationSeconds 30 -Execute -Confirm:$false 2>&1 | Out-Null }
    catch { $missingGate = $_.Exception.Message }
    Assert-True ($missingGate -match 'cost_gate_missing') 'Live execution must fail closed without approval evidence.'

    $priorKey = [Environment]::GetEnvironmentVariable('ELEVENLABS_API_KEY', 'Process')
    try {
        [Environment]::SetEnvironmentVariable('ELEVENLABS_API_KEY', $null, 'Process')
        $missingProvider = $null
        try {
            & $invokePath -OutputPath $outputPath -Prompt $prompt -DurationSeconds 30 -Execute -Confirm:$false -ApprovalEvidence 'fixture-only approval shape test' -ApprovedPromptSha256 (Get-TextSha256 $prompt) -ApprovedMaxCredits 450 2>&1 | Out-Null
        }
        catch { $missingProvider = $_.Exception.Message }
        Assert-True ($missingProvider -match 'provider_not_configured') 'Approved shape must still fail closed when the API key is absent.'
    }
    finally { [Environment]::SetEnvironmentVariable('ELEVENLABS_API_KEY', $priorKey, 'Process') }

    & node --check $helperPath
    if ($LASTEXITCODE -ne 0) { throw 'ElevenLabs Music Node request helper failed syntax validation.' }
    Assert-True ((Get-Content -LiteralPath $contractPath -Raw).Contains('One approval authorizes one request only')) 'BGM contract must retain the one-call stopping condition.'
    Assert-True ((Get-Content -LiteralPath $adapterPath -Raw).Contains('ELEVENLABS_API_KEY')) 'Provider adapter must document credential routing.'

    Write-Output 'PASS: BGM Production compiles one gated ElevenLabs Music v2 request, preserves prompt/duration/cost evidence, defaults to dry-run, and fails closed without approval or credentials.'
}
finally {
    if (Test-Path -LiteralPath $tempDirectory) { Remove-Item -LiteralPath $tempDirectory -Recurse -Force }
}
