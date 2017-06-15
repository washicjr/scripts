 [Reflection.Assembly]::LoadFrom("C:\sysutil\tmp\taglib-sharp.dll")
function getLyrics($mp3file){
    $mp3 = [TagLib.File]::Create($mp3file)
    $mp3Lyrics = $mp3.Tag.Lyrics
    if($mp3Lyrics.length -eq 0){
        return "NO LYRICS"
    }Else{
        return $mp3Lyrics
    }
}

get-childitem C:\sysutil\tmp\music -include *.mp3 -recurse | ForEach-Object ($_) {
    $mp3FileName = $_.FullName
    $lyricDirTmp = $_.Directory
    $lyricFileTmp = $_.Name
    
    $lyricDir = [string]$lyricDirTmp
    $lyricDir = $lyricDir + "\lyrics"
    $lyricFile = [string]$lyricFileTmp
    $lyricFile = $lyricFile -replace ".mp3", ".txt"
   
    $lyrics = getLyrics($mp3FileName)
    $lyrics = $lyrics -replace "taglib-sharp, Version=2.1.0.0, Culture=neutral, PublicKeyToken=db62eba44689b5b0", ""
    
  if($lyrics -ne "NO LYRICS"){
      write-host $LyricDir
      write-host $lyricFile
      $Lyrics | New-Item -path $lyricDir -Name $lyricFile -ItemType file -force
   }
}