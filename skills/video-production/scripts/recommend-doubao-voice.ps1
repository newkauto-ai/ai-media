[CmdletBinding()]
param(
    [string]$DatabasePath,
    [ValidateSet('narration', 'verification')]
    [string]$UseCase = 'narration',
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($DatabasePath)) {
    $DatabasePath = Join-Path (Split-Path -Parent $PSScriptRoot) 'data\voice-types.json'
}
if (-not (Test-Path -LiteralPath $DatabasePath -PathType Leaf)) { throw "Voice_Type database not found: $DatabasePath" }

$database = Get-Content -LiteralPath $DatabasePath -Raw -Encoding UTF8 | ConvertFrom-Json
$voices = @($database.voices | Where-Object { $_.provider -eq 'doubao_tts' -and $_.status -eq 'active' })
if ($voices.Count -eq 0) { throw 'Voice_Type database has no active Doubao voice.' }

$ranked = @(
    foreach ($voice in $voices) {
        $priority = if ($null -ne $voice.recommendation.priority) { [int]$voice.recommendation.priority } else { 0 }
        $useCases = @($voice.recommendation.use_cases)
        $styleTags = @($voice.recommendation.style_tags)
        $score = $priority
        if ($useCases -contains $UseCase) { $score += 20 }
        [pscustomobject]@{
            score = $score
            voice_id = $voice.voice_id
            voice_type = $voice.voice_type
            provider = $voice.provider
            language = $voice.language
            display_name = $voice.display_name
            rationale = $voice.recommendation.rationale
            style_tags = $styleTags
            source = $voice.source
        }
    }
)
$recommended = $ranked | Sort-Object -Property score, voice_id -Descending | Select-Object -First 1
$result = [pscustomobject]@{
    database_path = (Resolve-Path -LiteralPath $DatabasePath).Path
    use_case = $UseCase
    recommendation_basis = 'active Voice_Type records, priority, and use-case tags'
    recommended_voice = $recommended
    candidates = $ranked
}

if ($Json) {
    $result | ConvertTo-Json -Depth 10
}
else {
    Write-Output "RECOMMENDED: $($recommended.voice_type)"
    Write-Output "Use case: $UseCase"
    Write-Output "Reason: $($recommended.rationale)"
}
