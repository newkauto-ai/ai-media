[CmdletBinding(DefaultParameterSetName = 'Fixture')]
param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Fixture')][string]$FixturePath,
    [Parameter(Mandatory = $true, ParameterSetName = 'Media')][string]$VideoPath,
    [Parameter(Mandatory = $true, ParameterSetName = 'Media')][string]$LockedAudioPath,
    [Parameter(Mandatory = $true, ParameterSetName = 'Media')][string]$TargetRevision,
    [Parameter(Mandatory = $true, ParameterSetName = 'Media')][string]$ExpectedVideoSha256,
    [Parameter(Mandatory = $true, ParameterSetName = 'Media')][string]$ExpectedAudioSha256,
    [Parameter(Mandatory = $true, ParameterSetName = 'Media')][string]$ExpectedResolution,
    [Parameter(Mandatory = $true, ParameterSetName = 'Media')][double]$ExpectedFrameRate,
    [Parameter(Mandatory = $true, ParameterSetName = 'Media')][int]$ExpectedSampleRate,
    [Parameter(ParameterSetName = 'Media')][double]$EncodingToleranceSeconds = 0.0,
    [Parameter()][string]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function New-Assessment([string]$Verdict, [string[]]$Failures, [string[]]$Evidence, [string]$Source = 'deterministic_check') {
    [pscustomobject]@{ assessment = [pscustomobject]@{ source = $Source; run_id = $null; verdict = $Verdict; confidence = 'high'; evidence = $Evidence; failure_types = $Failures; affects_semantics = $false; requires_external_evidence = $false; proposed_capability = 'video-production' } }
}

function Get-Probe([string]$Path) {
    $ffprobe = (Get-Command ffprobe -ErrorAction Stop).Source
    $raw = & $ffprobe -v error -show_streams -show_format -of json -- $Path
    if ($LASTEXITCODE -ne 0) { throw "ffprobe failed for $Path" }
    return ($raw | ConvertFrom-Json)
}

function Convert-Rate([string]$Value) {
    if ($Value -match '^([0-9]+)\/([0-9]+)$' -and [double]$Matches[2] -gt 0) { return [double]$Matches[1] / [double]$Matches[2] }
    return [double]$Value
}

function Evaluate([object]$ProbeInput) {
    $required = @('video_sha256','locked_audio_sha256','target_revision','video_duration_seconds','audio_stream_duration_seconds','locked_audio_duration_seconds','resolution','frame_rate','sample_rate','has_audio','first_frame_decodable','last_frame_decodable','expected_resolution','expected_frame_rate','expected_sample_rate','encoding_tolerance_seconds')
    $missing = @($required | Where-Object { $property = @($ProbeInput.PSObject.Properties.Match($_) | Select-Object -First 1); $property.Count -eq 0 -or $null -eq $property[0].Value -or [string]::IsNullOrWhiteSpace([string]$property[0].Value) })
    if ($missing.Count -gt 0) { return (New-Assessment 'blocked' @() @("Missing bound probe fields: $($missing -join ', ')") 'fixture') }
    $failures = [System.Collections.Generic.List[string]]::new()
    $evidence = [System.Collections.Generic.List[string]]::new()
    $frameTolerance = 1.0 / [double]$ProbeInput.expected_frame_rate
    $tolerance = [math]::Max($frameTolerance, [double]$ProbeInput.encoding_tolerance_seconds)
    $audioDelta = [math]::Abs([double]$ProbeInput.audio_stream_duration_seconds - [double]$ProbeInput.locked_audio_duration_seconds)
    if ($audioDelta -gt $tolerance) { [void]$failures.Add('timing_failure') }
    if ([string]$ProbeInput.resolution -ne [string]$ProbeInput.expected_resolution -or [math]::Abs([double]$ProbeInput.frame_rate - [double]$ProbeInput.expected_frame_rate) -gt 0.01 -or [int]$ProbeInput.sample_rate -ne [int]$ProbeInput.expected_sample_rate) { [void]$failures.Add('output_spec_mismatch') }
    if (-not [bool]$ProbeInput.has_audio -or -not [bool]$ProbeInput.first_frame_decodable -or -not [bool]$ProbeInput.last_frame_decodable) { [void]$failures.Add('artifact') }
    [void]$evidence.Add("revision=$($ProbeInput.target_revision); video_sha256=$($ProbeInput.video_sha256); locked_audio_sha256=$($ProbeInput.locked_audio_sha256)")
    [void]$evidence.Add("audio_stream_delta_seconds=$audioDelta; tolerance_seconds=$tolerance; resolution=$($ProbeInput.resolution); frame_rate=$($ProbeInput.frame_rate); sample_rate=$($ProbeInput.sample_rate)")
    return (New-Assessment $(if ($failures.Count) { 'retry' } else { 'pass' }) $failures.ToArray() $evidence.ToArray() $(if ($ProbeInput.fixture_only) { 'fixture' } else { 'deterministic_check' }))
}

if ($PSCmdlet.ParameterSetName -eq 'Fixture') {
    $fixture = Get-Content -LiteralPath $FixturePath -Raw -Encoding UTF8 | ConvertFrom-Json
    if (-not $fixture.fixture_only) { throw 'Final Master fixture must be fixture_only.' }
    $results = foreach ($case in @($fixture.cases)) { [pscustomobject]@{ case_id = $case.case_id; expected_verdict = $case.expected_verdict; result = Evaluate $case.input } }
    $result = [pscustomobject]@{ fixture_only = $true; probe = 'final-master-technical'; cases = $results }
} else {
    foreach ($path in @($VideoPath, $LockedAudioPath)) { if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing bound media file: $path" } }
    $videoHash = (Get-FileHash -LiteralPath $VideoPath -Algorithm SHA256).Hash
    $audioHash = (Get-FileHash -LiteralPath $LockedAudioPath -Algorithm SHA256).Hash
    if ($videoHash -ne $ExpectedVideoSha256 -or $audioHash -ne $ExpectedAudioSha256) { $result = New-Assessment 'blocked' @() @('Bound file checksum does not match the supplied checksum.') }
    else {
        $video = Get-Probe $VideoPath; $audio = Get-Probe $LockedAudioPath
        $videoStream = @($video.streams | Where-Object { $_.codec_type -eq 'video' } | Select-Object -First 1); $audioStream = @($video.streams | Where-Object { $_.codec_type -eq 'audio' } | Select-Object -First 1); $lockedStream = @($audio.streams | Where-Object { $_.codec_type -eq 'audio' } | Select-Object -First 1)
        $ffmpeg = (Get-Command ffmpeg -ErrorAction Stop).Source
        & $ffmpeg -v error -i $VideoPath -frames:v 1 -f null - 2>$null; $firstOk = $LASTEXITCODE -eq 0
        & $ffmpeg -v error -sseof -1 -i $VideoPath -frames:v 1 -f null - 2>$null; $lastOk = $LASTEXITCODE -eq 0
        $input = [pscustomobject]@{ fixture_only = $false; video_sha256 = $videoHash; locked_audio_sha256 = $audioHash; target_revision = $TargetRevision; video_duration_seconds = [double]$video.format.duration; audio_stream_duration_seconds = if ($audioStream) { [double]$audioStream.duration } else { 0 }; locked_audio_duration_seconds = if ($lockedStream) { [double]$lockedStream.duration } else { 0 }; resolution = if ($videoStream) { "$($videoStream.width)x$($videoStream.height)" } else { '' }; frame_rate = if ($videoStream) { Convert-Rate $videoStream.avg_frame_rate } else { 0 }; sample_rate = if ($audioStream) { [int]$audioStream.sample_rate } else { 0 }; has_audio = ($null -ne $audioStream); first_frame_decodable = $firstOk; last_frame_decodable = $lastOk; expected_resolution = $ExpectedResolution; expected_frame_rate = $ExpectedFrameRate; expected_sample_rate = $ExpectedSampleRate; encoding_tolerance_seconds = $EncodingToleranceSeconds }
        $result = Evaluate $input
    }
}

if ($OutputPath) { $result | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $OutputPath -Encoding UTF8 } else { $result | ConvertTo-Json -Depth 12 }
