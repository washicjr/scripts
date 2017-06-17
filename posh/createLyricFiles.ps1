$crlf = "`r`n"
$musicSrc = "E:\.tmp\music"
$assemblyLoc = "C:\sysutil\git\scripts\lib\taglib-sharp.dll"

[Reflection.Assembly]::LoadFrom($assemblyLoc)

get-childitem $musicSrc -include *.m4a, *.mp3 -recurse | ForEach-Object ($_) {
    $musicFileName = $_.FullName
    $lyricDirTmp = $_.Directory
    $lyricFileTmp = $_.Name
    
    $music = [TagLib.File]::Create($musicFileName)
    $musicLyrics = $music.Tag.Lyrics
    if ( $musicLyrics.length -eq 0 ) { $musicLyrics = "NO LYRICS FOUND" }
    $musicLyrics = $musicLyrics -replace "taglib-sharp, Version=2.1.0.0, Culture=neutral, PublicKeyToken=db62eba44689b5b0", ""
   
    if ( $musicLyrics -ne "NO LYRICS FOUND" ) {
        $lyricDir = [string]$lyricDirTmp
        $lyricDir = $lyricDir + "\lyrics"
        $lyricFile = [string]$lyricFileTmp
        $lyricFile = $lyricFile -replace ".mp3", ".txt"
        $lyricFile = $lyricFile -replace ".m4a", ".txt"
        $fullPath = $lyricDir + "\" + $LyricFile

        $musicAlbumArtist = $music.Tag.AlbumArtists
        $musicAlbum = $music.Tag.Album
        $musicTitle = $music.Tag.Title
        $musicTrack = $music.Tag.Track
        $musicYear = $music.Tag.Year

        $LyricText =  "ALBUM ARTIST: " + $musicAlbumArtist + $crlf
        $LyricText = $lyricText + "ALBUM: " + $musicAlbum + $crlf
        $LyricText = $lyricText + "YEAR: " + $musicYear + $crlf
        $LyricText = $lyricText + "TRACK NUMBER: " + $musicTrack + $crlf
        $LyricText = $lyricText + "TRACK TITLE: " + $musicTitle + $crlf
        $LyricText = $lyricText + " " + $crlf
        $LyricText = $lyricText + "LYRICS: " + $crlf
        $LyricText = $LyricText + $musicLyrics
        $LyricText | New-Item -path $fullPath -ItemType file -force
   }
}
