#Requires -PSEdition Core

function funcNormalizeFileName($oldStr){
    $funcStr = $oldStr -replace '\d{2,4}\.', ''
    $funcStr = $funcStr -replace '\d{3,4}p.*\.mp4', '.mp4'
    $funcStr = $funcStr -replace '\.SD.*\.mp4', '.mp4'
    $funcStr = $funcStr -replace 'XXX.*\.mp4', '.mp4'
    $funcStr = $funcStr -replace 'KLEENEX.*\.mp4', '.mp4'
    $funcStr = $funcStr -replace '\-', ''
    $funcStr = $funcStr -replace '\s\s', ' '
    $funcStr = $funcStr -replace '\[', ''
    $funcStr = $funcStr -replace '\]', ''
    $funcStr = $funcStr -replace '\(', ''
    $funcStr = $funcStr -replace '\)', ''
    $funcStr = $funcStr -replace '\.MP4\.mp4', '.mp4'
    $funcStr = $funcStr -replace '\.', ' '
    $funcStr = $funcStr -replace '\s\s', ' '
    $funcStr = $funcStr -replace '\smp4', '.mp4'
    $funcStr = $funcStr -replace 'ArchAngel ', 'Archangel.'
    $funcStr = $funcStr -replace 'BBCParadise ', 'BBC Paradise.'
    $funcStr = $funcStr -replace 'BigCockBully ', 'Big Cock Bully.'
    $funcStr = $funcStr -replace 'BlackedRaw ', 'Blacked Raw.'
    $funcStr = $funcStr -replace 'Blackesonblondes ', 'Blackes on Blondes.'
    $funcStr = $funcStr -replace 'brothalovers ', 'Brotha Lovers.'
    $funcStr = $funcStr -replace 'dadcrush ', 'Dad Crush.'
    $funcStr = $funcStr -replace 'danejones ', 'Dane Jones.'
    $funcStr = $funcStr -replace 'deeper ', 'Deeper.'
    $funcStr = $funcStr -replace 'int3rracialpass ', 'Interracial Pass.'
    $funcStr = $funcStr -replace 'interracialpass ', 'Interracial Pass.'
    $funcStr = $funcStr -replace 'legalporno ', 'Legal Porno.'
    $funcStr = $funcStr -replace 'julesjordan ', 'Jules Jordan.'
    $funcStr = $funcStr -replace 'ManyVids ', 'Many Vids.'
    $funcStr = $funcStr -replace 'MonstersOfCock ', 'Monsters of Cock.'
    $funcStr = $funcStr -replace 'PureTaboo ', 'Pure Taboo.'
    $funcStr = $funcStr -replace 'sweetsinner ', 'Sweet Sinner.'
    $funcStr = $funcStr -replace 'teensloveblackcocks ', 'Teens Love Black Cocks.'
    $funcStr = $funcStr -replace 'wifeysworld ', 'Wifeys World.'
    $funcStr = $funcStr -replace ' and ', ' & '
    return $funcStr
}

function funcGetTitleCase($oldStr) {
    $textInfo = (Get-Culture).TextInfo
    $funcStr = $textInfo.ToTitleCase($oldStr.ToLower())
    $funcStr = $funcStr -replace ' A ', ' a '
    $funcStr = $funcStr -replace ' An ', ' an '
    $funcStr = $funcStr -replace ' And ', ' and '
    $funcStr = $funcStr -replace ' As ', ' as '
    $funcStr = $funcStr -replace ' At ', ' at '
    $funcStr = $funcStr -replace 'bbc', 'BBC'
    $funcStr = $funcStr -replace ' By ', ' by '
    $funcStr = $funcStr -replace ' For ', ' for '
    $funcStr = $funcStr -replace ' In ', ' in '
    $funcStr = $funcStr -replace ' Of ', ' of '
    $funcStr = $funcStr -replace ' On ', ' on '
    $funcStr = $funcStr -replace ' Or ', ' or '
    $funcStr = $funcStr -replace 'pawg', 'PAWG'
    $funcStr = $funcStr -replace ' Than ', ' than '
    $funcStr = $funcStr -replace ' The ', ' the '
    $funcStr = $funcStr -replace ' To ', ' to '
    $funcStr = $funcStr -replace ' With ', ' with '
    $funcStr = $funcStr -replace ' From ', ' from '
    return $funcStr
}

Get-ChildItem "E:\.tmp\.torrent\downloads\completed" -Recurse -File -Exclude *.mp3,*.m4a,*.flac,*.mp4,*.lnk,*.torrent, *.jpg | Remove-Item
Get-ChildItem "D:\sysutil\vm\vbox\hostshare" -Recurse -File -Exclude *.mp3,*.m4a,*.flac,*.mp4,*.lnk,*.torrent,*.jpg | Remove-Item

$processedDir = 'E:\.tmp\.torrent\downloads\completed\processed\'
if (-not (Test-Path -LiteralPath $processedDir)) {new-item $processedDir -itemtype directory}
Write-Host

$arFolders = @('E:\.tmp\.torrent\downloads\completed\','D:\sysutil\vm\vbox\hostshare\')
$arFolders | ForEach-Object {
    $searchSpec = $PSItem + '*.mp4'
    $files = Get-ChildItem $searchSpec -recurse
    ForEach ($file in $files){
        $newStr = $file.name
        $newStr = funcNormalizeFileName($newStr)
        $newStr = funcGetTitleCase($newStr)
        $newLoc = $processedDir + $newStr
        Move-Item $file.fullname $newLoc
        Write-Host OLDNAME $file.name NEWNAME $newStr
    }
}