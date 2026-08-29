[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string]$OutputPath,

    [Parameter(Mandatory = $true)]
    [ValidateLength(1, 4100)]
    [string]$Prompt,

    [ValidateRange(3, 600)]
    [int]$DurationSeconds,

    [ValidateSet('mp3_48000_192')]
    [string]$OutputFormat = 'mp3_48000_192',

    [string]$ApiKeyEnvironmentVariable = 'ELEVENLABS_API_KEY',

    [string]$ApprovalEvidence,

    [string]$ApprovedPromptSha256,

    [double]$ApprovedMaxCredits,

    [switch]$Execute
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-TextSha256 {
    param([string]$Text)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
        return ([System.BitConverter]::ToString($sha.ComputeHash($bytes))).Replace('-', '').ToLowerInvariant()
    }
    finally { $sha.Dispose() }
}

function Require-EnvironmentValue {
    param([string]$Name)
    $value = [Environment]::GetEnvironmentVariable($Name)
    if ([string]::IsNullOrWhiteSpace($value)) { throw "provider_not_configured: required environment variable '$Name' is missing." }
    return $value
}

$modelId = 'music_v2'
$endpoint = "https://api.elevenlabs.io/v1/music?output_format=$OutputFormat"
$promptSha256 = Get-TextSha256 $Prompt
$estimatedCredits = [math]::Ceiling(($DurationSeconds / 60.0) * 900.0)
$metadataPath = "$OutputPath.provider.json"
$payloadObject = [ordered]@{
    prompt = $Prompt
    music_length_ms = $DurationSeconds * 1000
    model_id = $modelId
    force_instrumental = $true
    sign_with_c2pa = $false
}

if (-not $Execute) {
    Write-Output 'DRY RUN: no network call occurred and no credits were consumed.'
    Write-Output "PROVIDER: elevenlabs_music"
    Write-Output "MODEL: $modelId"
    Write-Output "DURATION_SECONDS: $DurationSeconds"
    Write-Output "OUTPUT_FORMAT: $OutputFormat"
    Write-Output "ESTIMATED_CREDITS: $estimatedCredits"
    Write-Output "PROMPT_SHA256: $promptSha256"
    Write-Output "OUTPUT_PATH: $OutputPath"
    Write-Output "STOPPING_CONDITION: one request, then stop after download and technical integrity checks; no retry or assembly."
    return
}

if ([string]::IsNullOrWhiteSpace($ApprovalEvidence)) { throw 'cost_gate_missing: ApprovalEvidence is required for a live request.' }
if ([string]::IsNullOrWhiteSpace($ApprovedPromptSha256) -or $ApprovedPromptSha256.ToLowerInvariant() -ne $promptSha256) {
    throw "cost_gate_mismatch: approved prompt SHA-256 does not match the current prompt ($promptSha256)."
}
if ($ApprovedMaxCredits -lt $estimatedCredits) {
    throw "cost_gate_mismatch: approved credit ceiling $ApprovedMaxCredits is below estimated credits $estimatedCredits."
}
if (-not $PSCmdlet.ShouldProcess($OutputPath, "Generate one $DurationSeconds-second ElevenLabs Music v2 instrumental BGM")) { return }

$apiKey = Require-EnvironmentValue $ApiKeyEnvironmentVariable
$helperPath = Join-Path $PSScriptRoot 'elevenlabs-music-v2-request.mjs'
if (-not (Test-Path -LiteralPath $helperPath -PathType Leaf)) { throw "Request helper not found: $helperPath" }
$outputParent = Split-Path -Parent $OutputPath
if ($outputParent -and -not (Test-Path -LiteralPath $outputParent)) { New-Item -ItemType Directory -Force -Path $outputParent | Out-Null }

$env:ELEVENLABS_MUSIC_API_KEY = $apiKey
$env:ELEVENLABS_MUSIC_OUTPUT = [System.IO.Path]::GetFullPath($OutputPath)
$env:ELEVENLABS_MUSIC_METADATA_OUTPUT = [System.IO.Path]::GetFullPath($metadataPath)
$env:ELEVENLABS_MUSIC_PAYLOAD = $payloadObject | ConvertTo-Json -Depth 8 -Compress
$env:ELEVENLABS_MUSIC_ENDPOINT = $endpoint

try {
    & node $helperPath
    if ($LASTEXITCODE -ne 0) { throw "ElevenLabs Music request helper failed with exit code $LASTEXITCODE." }
}
finally {
    Remove-Item Env:ELEVENLABS_MUSIC_API_KEY -ErrorAction SilentlyContinue
    Remove-Item Env:ELEVENLABS_MUSIC_OUTPUT -ErrorAction SilentlyContinue
    Remove-Item Env:ELEVENLABS_MUSIC_METADATA_OUTPUT -ErrorAction SilentlyContinue
    Remove-Item Env:ELEVENLABS_MUSIC_PAYLOAD -ErrorAction SilentlyContinue
    Remove-Item Env:ELEVENLABS_MUSIC_ENDPOINT -ErrorAction SilentlyContinue
}

$file = Get-Item -LiteralPath $OutputPath
if ($file.Length -le 0) { throw "Generated BGM file is empty: $OutputPath" }
$hash = (Get-FileHash -LiteralPath $OutputPath -Algorithm SHA256).Hash.ToLowerInvariant()
$providerMetadata = Get-Content -LiteralPath $metadataPath -Raw -Encoding UTF8 | ConvertFrom-Json
$runtimeRecord = [ordered]@{
    provider = 'elevenlabs_music'
    model_id = $modelId
    output_format = $OutputFormat
    requested_duration_seconds = $DurationSeconds
    force_instrumental = $true
    estimated_credits = $estimatedCredits
    prompt_sha256 = $promptSha256
    approval_evidence = $ApprovalEvidence
    provider_song_id = $providerMetadata.provider_song_id
    provider_request_id = $providerMetadata.provider_request_id
    content_type = $providerMetadata.content_type
    downloaded_bytes = $file.Length
    checksum_sha256 = $hash
    generated_at = (Get-Date).ToUniversalTime().ToString('o')
    qa_status = 'technical_file_received_awaiting_decode_duration_and_human_listening'
}
$runtimeRecord | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $metadataPath -Encoding UTF8

Write-Output "GENERATED: $OutputPath"
Write-Output "METADATA: $metadataPath"
Write-Output "BYTES: $($file.Length)"
Write-Output "SHA256: $hash"
Write-Output 'STOPPED: no retry, edit, mix, or assembly was performed.'
