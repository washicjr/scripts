$musicSrc = "E:\.tmp\music\mp3"
$assemblyLoc = "C:\sysutil\git\scripts\posh\modules\ID3\1.1\taglib-sharp.dll"
[Reflection.Assembly]::LoadFrom($assemblyLoc)
function getLyrics($musicfile){
    $music = [TagLib.File]::Create($musicfile)
    $musicLyrics = $music.Tag.Lyrics
    if($musicLyrics.length -eq 0){
        return "NO LYRICS"
    }Else{
        return $musicLyrics
    }
}

get-childitem $musicSrc -include *.mp3 -recurse | ForEach-Object ($_) {
    $musicFileName = $_.FullName
    $lyricDirTmp = $_.Directory
    $lyricFileTmp = $_.Name
    
    $lyricDir = [string]$lyricDirTmp
    $lyricDir = $lyricDir + "\lyrics"
    $lyricFile = [string]$lyricFileTmp
    $lyricFile = $lyricFile -replace ".mp3", ".txt"
   
    $lyrics = getLyrics($musicFileName)
    $lyrics = $lyrics -replace "taglib-sharp, Version=2.1.0.0, Culture=neutral, PublicKeyToken=db62eba44689b5b0", ""
    
  if($lyrics -ne "NO LYRICS"){
      $fullPath = $lyricDir + "\" + $LyricFile
      $Lyrics | New-Item -path $fullPath -ItemType file -force
   }
}
