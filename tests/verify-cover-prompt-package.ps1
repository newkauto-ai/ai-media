[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'helpers\publishing-packaging-test-helpers.ps1')
$temp = Join-Path ([System.IO.Path]::GetTempPath()) ('skill5-cover-prompt-' + [guid]::NewGuid().ToString('N'))

try {
    New-Item -ItemType Directory -Force -Path $temp | Out-Null
    $inputPath = Join-Path $root 'tests\fixtures\rainy-day-kitten-cover-prompt.input.json'
    $input = Get-Content -LiteralPath $inputPath -Raw -Encoding UTF8 | ConvertFrom-Json
    Assert-True ($null -eq $input.source_artifact -and $input.execution_mode.cover_prompt_only) 'Rainy-day early path must not depend on Final Media.'
    $run = Invoke-Skill5Compile -InputObject $input -TempRoot $temp -ProjectRoot $root -Name 'rainy-cover-prompt'
    Assert-True ($run.ExitCode -eq 0) 'Rainy-day Cover Prompt Packages must compile locally.'
    $xhs = Get-Content -LiteralPath (Join-Path $run.OutputPath 'xiaohongshu\publish-package.json') -Raw -Encoding UTF8 | ConvertFrom-Json
    $douyin = Get-Content -LiteralPath (Join-Path $run.OutputPath 'douyin\publish-package.json') -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($package in @($xhs, $douyin)) {
        Assert-True ($package.schema_version -eq '1.2' -and $package.package_version -eq '1.2') 'Publish Package v1.2 must be explicit.'
        Assert-True ($package.cover_prompt.compiler_reuse -eq 'video-production/scripts/compile-image-prompt-fixture.ps1') 'Skill 5 must reuse the existing Video Production image Prompt compiler.'
        Assert-True ($package.cover_prompt.image_prompt_spec.prompt_variant -eq 'cover_visual' -and $package.cover_prompt.image_prompt_spec.contract_version -eq '1.2') 'Cover visual must use the additive image Prompt variant.'
        Assert-True (@($package.cover_prompt.reference_bindings).Count -eq 3) 'All approved character/keyframe references must keep checksum bindings.'
        Assert-True ($package.cover_prompt.call_package.generation_status -eq 'not_authorized') 'Local prompt compilation must not authorize paid generation.'
        Assert-True ($package.cover_prompt.overlay_spec.generate_text_in_image -eq $false) 'Exact Chinese must remain a programmatic overlay.'
        Assert-True ($package.readiness.status -eq 'PACKAGE_DRAFT') 'No Final Media means Publish Package remains Draft.'
    }
    Assert-True ($xhs.titles.story_hook -eq $douyin.titles.story_hook) 'Story Hook remains shared upstream truth.'
    Assert-True ($xhs.titles.platform_title -ne $douyin.titles.platform_title -and $xhs.titles.cover_title -ne $douyin.titles.cover_title) 'Platform and Cover Titles must be independent per platform.'
    Assert-True ($xhs.cover_prompt.prompt_package_hash -ne $douyin.cover_prompt.prompt_package_hash) 'Platform-native Cover Prompt hashes must differ.'
    Assert-True ($xhs.cover_prompt.executable_prompt -match '3:4 editorial relationship frame' -and $douyin.cover_prompt.executable_prompt -match '9:16 concentrated action frame') 'Xiaohongshu and Douyin must compile independent composition semantics, not mechanical crops.'
    Write-Output 'PASS: Rainy-day approved references compile independent Xiaohongshu/Douyin Cover Prompt Packages before Final Media through the existing image Prompt compiler with zero generation authorization.'
}
finally {
    if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Recurse -Force }
}
