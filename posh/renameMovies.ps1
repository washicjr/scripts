#Requires -PSEdition Core

function funcGetTitleCase($oldStr) {
    $textInfo = (Get-Culture).TextInfo
    $funcStr = $textInfo.ToTitleCase($oldStr.ToLower())
    $funcStr = $funcStr -replace ' A ', ' a '
    $funcStr = $funcStr -replace ' An ', ' an '
    $funcStr = $funcStr -replace ' And ', ' and '
    $funcStr = $funcStr -replace ' As ', ' as '
    $funcStr = $funcStr -replace ' At ', ' at '
    $funcStr = $funcStr -replace ' For ', ' for '
    $funcStr = $funcStr -replace ' In ', ' in '
    $funcStr = $funcStr -replace ' Of ', ' of '
    $funcStr = $funcStr -replace ' On ', ' on '
    $funcStr = $funcStr -replace ' Or ', ' or '
    $funcStr = $funcStr -replace ' The ', ' the '
    $funcStr = $funcStr -replace ' To ', ' to '
    $funcStr = $funcStr -replace ' With ', ' with '
    $funcStr = $funcStr -replace ' From ', ' from '
    return $funcStr
}

Get-ChildItem "E:\.tmp\.torrent\downloads\completed" -Recurse -File -Exclude *.mp3,*.m4a,*.flac,*.mp4,*.lnk, *.jpg | Remove-Item
Get-ChildItem "D:\sysutil\vm\vbox\hostshare" -Recurse -File -Exclude *.mp3,*.m4a,*.flac,*.mp4,*.lnk,*.jpg | Remove-Item

$processedDir = 'E:\.tmp\.torrent\downloads\completed\processed\'
if (-not (Test-Path -LiteralPath $processedDir)) {new-item $processedDir -itemtype directory}
Write-Host

$arFolders = @('E:\.tmp\.torrent\downloads\completed\','D:\sysutil\vm\vbox\hostshare\')
$arFolders | ForEach-Object {
    $searchSpec = $PSItem + '*.mp4'
    $files = Get-ChildItem $searchSpec -recurse
    ForEach ($file in $files){
        $strName = $file.name
        $strName = $strName -replace '\d{2,4}\.', ''
        $strName = $strName -replace '\d{3,4}p.*\.mp4', '.mp4'
        $strName = $strName -replace '\.SD.*\.mp4', '.mp4'
        $strName = $strName -replace 'XXX.*\.mp4', '.mp4'
        $strName = $strName -replace 'KLEENEX.*\.mp4', '.mp4'
        $strName = $strName -replace '\-', ''
        $strName = $strName -replace '\s\s', ' '
        $strName = $strName -replace '\[', ''
        $strName = $strName -replace '\]', ''
        $strName = $strName -replace '\(', ''
        $strName = $strName -replace '\)', ''
        $strName = $strName -replace '\.MP4\.mp4', '.mp4'
        $strName = $strName -replace '\.', ' '
        $strName = $strName -replace '\s\s', ' '
        $strName = $strName -replace '\smp4', '.mp4'
        $strName = $strName -replace 'ArchAngel ', 'Archangel.'
        $strName = $strName -replace 'BBCParadise ', 'BBC Paradise.'
        $strName = $strName -replace 'BigCockBully ', 'Big Cock Bully.'
        $strName = $strName -replace 'BlackedRaw ', 'Blacked Raw.'
        $strName = $strName -replace 'Blackesonblondes ', 'Blackes on Blondes.'
        $strName = $strName -replace 'brothalovers ', 'Brotha Lovers.'
        $strName = $strName -replace 'dadcrush ', 'Dad Crush.'
        $strName = $strName -replace 'danejones ', 'Dane Jones.'
        $strName = $strName -replace 'deeper ', 'Deeper.'
        $strName = $strName -replace 'int3rracialpass ', 'Interracial Pass.'
        $strName = $strName -replace 'interracialpass ', 'Interracial Pass.'
        $strName = $strName -replace 'julesjordan ', 'Jules Jordan.'
        $strName = $strName -replace 'ManyVids ', 'Many Vids.'
        $strName = $strName -replace 'MonstersOfCock ', 'Monsters of Cock.'
        $strName = $strName -replace 'PureTaboo ', 'Pure Taboo.'
        $strName = $strName -replace 'sweetsinner ', 'Sweet Sinner.'
        $strName = $strName -replace 'teensloveblackcocks ', 'Teens Love Black Cocks.'
        $strName = $strName -replace ' and ', ' & '

        $newName = funcGetTitleCase($strName)
        $newLoc = $processedDir + $newName
        
        Write-Host OLDNAME $file.name NEWNAME $newName
        Move-Item $file.fullname $newLoc
    }
}