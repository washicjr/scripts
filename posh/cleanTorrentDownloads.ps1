Get-ChildItem "E:\.tmp\.torrent\downloads\completed" -Recurse -File -Exclude *.mp3,*.m4a,*.flac,*.mp4, *.jpg | Remove-Item
Get-ChildItem "D:\sysutil\vm\vbox\hostshare" -Recurse -File -Exclude *.mp3,*.m4a,*.flac,*.mp4, *.jpg | Remove-Item
