function getLyrics($mp3file){
    [Reflection.Assembly]::LoadFrom("C:\sysutil\tmp\taglib-sharp.dll")
    $mp3 = [TagLib.File]::Create($mp3file)
    $mp3Lyrics = $mp3.Tag.Lyrics
    if($mp3Lyrics.length -eq 0){
        return "NO LYRICS"
    }Else{
        return $mp3Lyrics
    }
}

get-childitem E:\.tmp\music\mp3 -include *.mp3 -recurse | ForEach-Object ($_) {
    $mp3FileName = $_.FullName
    $lyrics = getLyrics($mp3FileName)
    $lyrics = $lyrics -replace "taglib-sharp, Version=2.1.0.0, Culture=neutral, PublicKeyToken=db62eba44689b5b0", ""
    
    $lyricDir = [string]$_.Directory + "\lyrics"
    $lyricFile = $_.Name
    $lyricFile = $lyricFile -replace ".mp3", ".txt"
    $lyricFile = $lyricDir + "\" + $lyricFile

  if($lyrics -ne "NO LYRICS"){
      if (! (test-path $lyricDir)){
        New-Item $lyricDir -type directory
      }
      $Lyrics | Out-File -FilePath $LyricFile
   }
}