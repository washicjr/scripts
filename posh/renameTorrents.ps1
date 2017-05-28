Set-Location C:\sysutil\vm\vbox\hostshare
Get-ChildItem | rename-item -newname { $_.Name +".torrent" }