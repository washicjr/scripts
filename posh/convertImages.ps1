$sourceDir = "E:\.tmp\music\.meta\art\album"
Get-ChildItem $sourceDir -Recurse -File | ForEach-Object {
    $imageFile = $_.fullname
    $imagePath = $_.directoryName
    D:\users\Clarence\OneDrive\sysutil\bin\nconvertCmdLine\nconvert.exe -o $imagePath\cover.jpg -out jpeg -q 100 -resize 1400 1400 -dpi 72 -rtype linear -rmeta -overwrite $imageFile
}
Get-ChildItem $sourceDir -Recurse -File -Exclude cover.jpg | Remove-Item
explorer E:\.tmp\music\.meta\art\album