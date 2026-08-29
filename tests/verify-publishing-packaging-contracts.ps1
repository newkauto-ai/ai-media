[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'helpers\publishing-packaging-test-helpers.ps1')
$temp = Join-Path ([System.IO.Path]::GetTempPath()) ('skill5-contracts-' + [guid]::NewGuid().ToString('N'))

try {
    New-Item -ItemType Directory -Force -Path $temp | Out-Null
    $python = Get-Skill5Python
    & $python -m py_compile (Join-Path $root 'publishing-packaging\scripts\publishing_packaging_runtime.py')
    Assert-True ($LASTEXITCODE -eq 0) 'Python runtime must compile.'

    $skill = Get-Content -LiteralPath (Join-Path $root 'publishing-packaging\SKILL.md') -Raw -Encoding UTF8
    $inputContract = Get-Content -LiteralPath (Join-Path $root 'publishing-packaging\contracts\input-contract.md') -Raw -Encoding UTF8
    $packageContract = Get-Content -LiteralPath (Join-Path $root 'publishing-packaging\contracts\publish-package-contract.md') -Raw -Encoding UTF8
    $legacyContract = Get-Content -LiteralPath (Join-Path $root 'script-engine\contracts\skill3-handoff-contract.md') -Raw -Encoding UTF8
    Assert-True ($skill.Contains('READY_FOR_MANUAL_UPLOAD') -and $skill.Contains('never calls a model')) 'Skill entry must preserve local-only and generation boundaries.'
    Assert-True ($inputContract.Contains('fixture_only') -and $inputContract.Contains('shadow_only') -and $inputContract.Contains('SOURCE_BLOCKED')) 'Input contract must declare safety and source gates.'
    Assert-True ($packageContract.Contains('No V1 state may be named') -and $packageContract.Contains('package_hash')) 'Package contract must exclude publish states and bind hashes.'
    Assert-True ($legacyContract.Contains('legacy/provisional') -and $legacyContract.Contains('final_owner: publishing_packaging')) 'Skill 2 packaging must remain readable but migrate final authority.'

    $missing = [ordered]@{ schema_version = '1.1'; publishing_context = @{ target_platforms = @() } }
    $missingRun = Invoke-Skill5Compile -InputObject $missing -TempRoot $temp -ProjectRoot $root -Name 'platform-missing'
    Assert-True ($missingRun.ExitCode -eq 2) 'Missing platform selection must return the ask-user blocked code.'
    $missingIndex = Get-Content -LiteralPath (Join-Path $missingRun.OutputPath 'index.json') -Raw -Encoding UTF8 | ConvertFrom-Json
    Assert-True ($missingIndex.status -eq 'BLOCKED' -and @($missingIndex.packages).Count -eq 0 -and $missingIndex.next_action -eq 'ask_user') 'Missing platform selection must emit zero packages.'

    $video = Join-Path $temp 'source.mp4'
    New-Skill5TestVideo -Path $video
    $input = New-Skill5BaseInput -VideoPath $video -Platforms @('youtube_shorts') -FixtureOnly $true
    $input.platform_copy = @{}
    $legacyRun = Invoke-Skill5Compile -InputObject $input -TempRoot $temp -ProjectRoot $root -Name 'legacy'
    Assert-True ($legacyRun.ExitCode -eq 0) 'Legacy compatibility compilation must succeed locally.'
    $legacyPackage = Get-Content -LiteralPath (Join-Path $legacyRun.OutputPath 'youtube_shorts\publish-package.json') -Raw -Encoding UTF8 | ConvertFrom-Json
    Assert-True ($legacyPackage.copy.source -eq 'skill2_legacy_provisional_hint') 'Skill 2 hint must be readable.'
    Assert-True ($legacyPackage.strategy.final_packaging_authority -eq 'publishing_packaging') 'Skill 5 must own final output.'
    Assert-True ($legacyPackage.readiness.status -eq 'PACKAGE_DRAFT') 'A Fixture must never become Ready.'
    Assert-True (@($legacyPackage.review.upstream_review_refs).Count -eq 1 -and $legacyPackage.review.review_policy_version -eq 'publishing-packaging-v1.2') 'Upstream Review v2.1 must remain a reference, not the package review.'
    Assert-True (-not ($legacyPackage.PSObject.Properties.Name -contains 'retry_count')) 'Skill 5 must not own or modify retry count.'

    $bad = New-Skill5BaseInput -VideoPath $video -Platforms @('youtube_shorts') -FixtureOnly $true
    $bad.source_artifact.checksum_sha256 = ('0' * 64)
    $badRun = Invoke-Skill5Compile -InputObject $bad -TempRoot $temp -ProjectRoot $root -Name 'bad-source'
    Assert-True ($badRun.ExitCode -eq 0) 'Blocked source must compile an auditable Package record.'
    $badPackage = Get-Content -LiteralPath (Join-Path $badRun.OutputPath 'youtube_shorts\publish-package.json') -Raw -Encoding UTF8 | ConvertFrom-Json
    Assert-True ($badPackage.readiness.status -eq 'SOURCE_BLOCKED' -and $badPackage.readiness.stale) 'Checksum mismatch must be SOURCE_BLOCKED and stale.'

    $provisional = New-Skill5BaseInput -VideoPath $video -Platforms @('youtube_shorts') -FinalQaStatus 'provisional' -FixtureOnly $false
    $provisionalRun = Invoke-Skill5Compile -InputObject $provisional -TempRoot $temp -ProjectRoot $root -Name 'provisional'
    $provisionalPackage = Get-Content -LiteralPath (Join-Path $provisionalRun.OutputPath 'youtube_shorts\publish-package.json') -Raw -Encoding UTF8 | ConvertFrom-Json
    Assert-True ($provisionalPackage.readiness.status -eq 'PACKAGE_DRAFT') 'Provisional source must not exceed PACKAGE_DRAFT.'

    $fixtureCases = Get-Content -LiteralPath (Join-Path $root 'tests\fixtures\publishing-packaging-cases.json') -Raw -Encoding UTF8 | ConvertFrom-Json
    Assert-True (@($fixtureCases.cases).Count -ge 12) 'Seeded cases must cover the acceptance risk matrix.'
    $skillRoot = Join-Path $root 'publishing-packaging'
    $skillMirror = Join-Path $root 'skills\publishing-packaging'
    $rootFiles = Get-ChildItem -LiteralPath $skillRoot -Recurse -File | Where-Object { $_.FullName -notmatch '__pycache__' }
    foreach ($file in $rootFiles) {
        $relative = [System.IO.Path]::GetRelativePath($skillRoot, $file.FullName)
        $mirror = Join-Path $skillMirror $relative
        Assert-True (Test-Path -LiteralPath $mirror) "Skill mirror missing: $relative"
        Assert-True ((Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash -eq (Get-FileHash -LiteralPath $mirror -Algorithm SHA256).Hash) "Skill mirror hash mismatch: $relative"
    }
    Write-Output 'PASS: Skill 5 contracts enforce platform selection, immutable source binding, legacy compatibility/final ownership, upstream Review references, provisional/Fixture withholding, and zero retry authority.'
}
finally {
    if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Recurse -Force }
}
