$workingDir = 'E:\.tmp\music'
$mp3Dir = $workingDir + '\mp3'
$alacDir = $workingDir + '\alac'
$m4aDir = $workingDir + '\m4a'
$flacDir = $workingDir + '\flac'

if (-not (Test-Path -LiteralPath $mp3Dir )) {new-item $mp3Dir -itemtype directory}
if (-not (Test-Path -LiteralPath $alacDir)) {new-item $alacDir -itemtype directory}
if (-not (Test-Path -LiteralPath $m4aDir)) {new-item $m4aDir -itemtype directory}
if (-not (Test-Path -LiteralPath $flacDir)) {new-item $flacDir -itemtype directory}