# Rebuild the original offline mission-control clips on Windows.
$ErrorActionPreference = 'Stop'
$voiceDirectory = Join-Path $PSScriptRoot 'game/voice'
$lines = Get-Content -Raw -LiteralPath (Join-Path $voiceDirectory 'lines.json') | ConvertFrom-Json

$voice = New-Object -ComObject SAPI.SpVoice
foreach ($candidate in $voice.GetVoices()) {
    if ($candidate.GetDescription() -like 'Microsoft Hazel*') {
        $voice.Voice = $candidate
        break
    }
}
$voice.Rate = -1
$cueSheet = [ordered] @{}
foreach ($line in $lines.PSObject.Properties) {
    $clipPath = Join-Path $voiceDirectory ($line.Name + '.wav')
    $stream = New-Object -ComObject SAPI.SpFileStream
    $stream.Format.Type = 22 # 22.05 kHz, 16-bit mono PCM
    $stream.Open($clipPath, 3, $false)
    try {
        $voice.AudioOutputStream = $stream
        $cues = foreach ($sentence in ($line.Value -split '(?<=\.)\s+')) {
            $start = [Math]::Round($stream.Seek(0, 1) / 44100.0, 3)
            [void] $voice.Speak($sentence)
            [ordered] @{ at = $start; text = $sentence }
        }
        $cueSheet[$line.Name] = @($cues)
    }
    finally {
        $stream.Close()
    }
}
$json = ConvertTo-Json -InputObject $cueSheet -Depth 5
[IO.File]::WriteAllText((Join-Path $voiceDirectory 'captions.json'), $json)
