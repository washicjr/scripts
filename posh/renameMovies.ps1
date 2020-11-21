#Requires -PSEdition Core

Get-ChildItem "E:\.tmp\.torrent\downloads\completed" -Recurse -File -Exclude *.mp3,*.m4a,*.flac,*.mp4, *.jpg | Remove-Item
Get-ChildItem "D:\sysutil\vm\vbox\hostshare" -Recurse -File -Exclude *.mp3,*.m4a,*.flac,*.mp4, *.jpg | Remove-Item

$processedDir = 'E:\.tmp\.torrent\downloads\completed\processed\'
if (-not (Test-Path -LiteralPath $processedDir)) {new-item $processedDir -itemtype directory}
Write-Host

$arFolders = @('E:\.tmp\.torrent\downloads\completed\','D:\sysutil\vm\vbox\hostshare\')
$arFolders | ForEach-Object {
    $searchSpec = $PSItem + '*.mp4'
    $files = Get-ChildItem $searchSpec -recurse
    ForEach ($file in $files){
        $name = $file.name
        $name = $name -replace '\d{2,4}\.', ''
        $name = $name -replace '\d{3,4}p.*\.mp4', '.mp4'
        $name = $name -replace '\.SD.*\.mp4', '.mp4'
        $name = $name -replace 'XXX.*\.mp4', '.mp4'
        $name = $name -replace 'KLEENEX.*\.mp4', '.mp4'
        $name = $name -replace '\-', ''
        $name = $name -replace '\s\s', ' '
        $name = $name -replace '\[', ''
        $name = $name -replace '\]', ''
        $name = $name -replace '\(', ''
        $name = $name -replace '\)', ''
        $name = $name -replace '\.MP4\.mp4', '.mp4'
        $name = $name -replace '\.', ' '
        $name = $name -replace '\s\s', ' '
        $name = $name -replace '\smp4', '.mp4'
        $name = $name -replace 'ArchAngel', 'Archangel'
        $name = $name -replace 'BBCParadise', 'BBC Paradise'
        $name = $name -replace 'BigCockBully', 'Big Cock Bully'
        $name = $name -replace 'BlackedRaw', 'Blacked Raw'
        $name = $name -replace 'brothalovers', 'Brotha Lovers'
        $name = $name -replace 'danejones', 'Dane Jones'
        $name = $name -replace 'int3rracialpass', 'Interracial Pass'
        $name = $name -replace 'interracialpass', 'Interracial Pass'
        $name = $name -replace 'ManyVids', 'Many Vids'
        $name = $name -replace 'julesjordan', 'Jules Jordan'
        $name = $name -replace 'MonstersOfCock', 'Monsters of Cock'
        $name = $name -replace 'PureTaboo', 'Pure Taboo'
        $name = $name -replace 'sweetsinner', 'Sweet Sinner'
        $name = $name -replace 'teensloveblackcocks', 'Teens Love Black Cocks'
        $newLoc = $processedDir + $name
        
        Write-Host OLDNAME $file.name NEWNAME $name
        Move-Item $file.fullname $newLoc
    }
}