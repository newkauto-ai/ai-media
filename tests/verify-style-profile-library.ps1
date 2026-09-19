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

$dreamyGardenEntry = @($registry.profiles | Where-Object { $_.profile_id -eq 'dreamy_garden_poetic_healing' })
Assert-True ($dreamyGardenEntry.Count -eq 1) 'Dreamy garden poetic healing must resolve to one stable profile ID.'
Assert-True ($dreamyGardenEntry[0].status -eq 'pending_review') 'New dreamy garden profile must remain pending_review until real LookDev acceptance.'
$dreamyGardenProfile = Get-Content -LiteralPath (Join-Path $normalizedDir $dreamyGardenEntry[0].normalized_file) -Raw | ConvertFrom-Json
Assert-True ($dreamyGardenProfile.style_profile.display_name -eq '梦幻园林诗意治愈风') 'Dreamy garden profile must preserve the user-visible Chinese name.'
Assert-True ($dreamyGardenProfile.style_profile.audiovisual_modules.visual_identity.medium -contains '二维数字手绘') 'Dreamy garden profile must retain its illustrated medium and remain distinct from the live-action pastoral profile.'
Assert-True ($dreamyGardenProfile.style_profile.production_modules.model_adapter_reference.model_syntax_locked -eq $false) 'Dreamy garden profile must keep model syntax replaceable.'

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
