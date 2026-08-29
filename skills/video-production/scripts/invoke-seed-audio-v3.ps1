[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string]$OutputPath,

    [Parameter(Mandatory = $true)]
    [string]$TextPrompt,

    [string]$ApiKeyEnvironmentVariable = 'VOLCENGINE_TTS_V3_API_KEY',

    [switch]$Execute
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Require-EnvironmentValue {
    param([string]$Name)
    $value = [Environment]::GetEnvironmentVariable($Name)
    if ([string]::IsNullOrWhiteSpace($value)) { throw "not_configured: required environment variable '$Name' is missing." }
    return $value
}

$helperPath = Join-Path $PSScriptRoot 'seed-audio-v3-request.mjs'
if (-not (Test-Path -LiteralPath $helperPath -PathType Leaf)) { throw "Request helper not found: $helperPath" }
if (-not $Execute) {
    Write-Output "DRY RUN: would call Seed Audio 1.0 V3 and write $OutputPath; no network call occurred."
    return
}
if (-not $PSCmdlet.ShouldProcess($OutputPath, 'Generate Seed Audio 1.0 V3 test audio')) { return }

$apiKey = Require-EnvironmentValue $ApiKeyEnvironmentVariable
$outputParent = Split-Path -Parent $OutputPath
if ($outputParent -and -not (Test-Path -LiteralPath $outputParent)) { New-Item -ItemType Directory -Force -Path $outputParent | Out-Null }

$payload = [ordered]@{
    model = 'seed-audio-1.0'
    text_prompt = $TextPrompt
    audio_config = [ordered]@{
        format = 'mp3'
        sample_rate = 48000
        pitch_rate = 0
        speech_rate = 0
        loudness_rate = 0
    }
    watermark = [ordered]@{}
} | ConvertTo-Json -Depth 8 -Compress

$env:VOLCENGINE_SEED_AUDIO_API_KEY = $apiKey
$env:VOLCENGINE_SEED_AUDIO_OUTPUT = [System.IO.Path]::GetFullPath($OutputPath)
$env:VOLCENGINE_SEED_AUDIO_PAYLOAD = $payload
$env:VOLCENGINE_SEED_AUDIO_ENDPOINT = 'https://openspeech.bytedance.com/api/v3/tts/create'

& node $helperPath
if ($LASTEXITCODE -ne 0) { throw "Seed Audio request helper failed with exit code $LASTEXITCODE." }

$file = Get-Item -LiteralPath $OutputPath
if ($file.Length -le 0) { throw "Generated audio file is empty: $OutputPath" }
$hash = (Get-FileHash -LiteralPath $OutputPath -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Output "GENERATED: $OutputPath"
Write-Output "BYTES: $($file.Length)"
Write-Output "SHA256: $hash"
