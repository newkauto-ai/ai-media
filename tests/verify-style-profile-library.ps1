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
