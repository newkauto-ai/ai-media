param(
    [string]$ProjectRoot
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($ProjectRoot)) {
    $skillRoot = Split-Path -Parent $PSScriptRoot
    $ProjectRoot = Split-Path -Parent $skillRoot
}

$sourceDir = Join-Path $ProjectRoot 'style-profiles\source'
$normalizedDir = Join-Path $ProjectRoot 'style-profiles\normalized'
$registryPath = Join-Path $ProjectRoot 'style-profiles\registry.json'

if (-not (Test-Path -LiteralPath $sourceDir)) { throw "Missing source directory: $sourceDir" }
if (-not (Test-Path -LiteralPath $normalizedDir)) { throw "Missing normalized directory: $normalizedDir" }
if (-not (Test-Path -LiteralPath $registryPath)) { throw "Missing registry: $registryPath" }

$registry = Get-Content -LiteralPath $registryPath -Raw | ConvertFrom-Json
$results = foreach ($source in Get-ChildItem -LiteralPath $sourceDir -File -Filter '*.md' | Sort-Object Name) {
    $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $source.FullName).Hash
    $entry = @($registry.profiles | Where-Object { $_.source_file -eq $source.Name })

    if ($entry.Count -eq 0) {
        [pscustomobject]@{ source_file = $source.Name; source_sha256 = $hash; status = 'pending_normalization'; profile_id = $null; normalized_file = $null }
        continue
    }

    $record = $entry[0]
    if ($record.source_sha256 -ne $hash) {
        [pscustomobject]@{ source_file = $source.Name; source_sha256 = $hash; status = 'source_changed'; profile_id = $record.profile_id; normalized_file = $record.normalized_file }
        continue
    }

    $normalizedPath = Join-Path $normalizedDir $record.normalized_file
    $status = if (Test-Path -LiteralPath $normalizedPath) { $record.status } else { 'pending_normalization' }
    [pscustomobject]@{ source_file = $source.Name; source_sha256 = $hash; status = $status; profile_id = $record.profile_id; normalized_file = $record.normalized_file }
}

$results | ConvertTo-Json -Depth 5
