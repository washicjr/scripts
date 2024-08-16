#Requires -PSEdition Core

Get-ChildItem "E:\.tmp\.torrent\downloads\completed" -Recurse -File -Exclude *.sit, *.srt, *.xml, *.mkv, *.mp3,*.m4a,*.flac,*.mp4, cover.jpg | Remove-Item
