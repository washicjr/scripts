Push-Location -Path D:\users\clarence\Downloads
notepad.exe
. .\set-window.ps1
Start-Sleep -Seconds 5
Get-Process Notepad | Set-Window -X 20 -Y 20 -Width 400 -Height 1000 -Passthru
