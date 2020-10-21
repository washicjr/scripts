$workingDir = Convert-Path .
$csvRawDir = $workingDir + '\raw\'
$csvStp1Dir = $workingDir + '\stp1\'
$csvFinDir = $workingDir + '\fin\'

Write-Host
Write-Host Parsing CompSource Mututals Employees Data
if (-not (Test-Path -LiteralPath $csvRawDir)) {new-item $csvRawDir -itemtype directory}
if (-not (Test-Path -LiteralPath $csvStp1Dir)) {new-item $csvStp1Dir -itemtype directory}
if (-not (Test-Path -LiteralPath $csvFinDir)) {new-item $csvFinDir -itemtype directory}

$files = Get-ChildItem $csvRawDir\*.csv

ForEach ($file in $files){
  $csvDoc = $file.Name
  $stp1OutCSV = $csvStp1Dir + $csvDoc
  $finOutCSV = $csvfinDir + $csvDoc
  $origInputFile = $file.FullName

  Write-Host Initial Filtering of Records $LogsUpper
  Import-Csv  $origInputFile | 
  Where-Object {(($_."nPhoneNumber" -ne "(405) 962-3897") -and ($_.nPhoneNumber -ne "(918) 295-1503"))} |
  Export-Csv $stp1OutCSV –NoTypeInformation
  
  Write-Host Loading document into memory and dropping unecessary columns:  $origInputfile
  Import-Csv  $stp1OutCSV | Select-Object @{Name = "sEmailAddress"; Expression = {($_."sEmailAddress").ToLower()}},
    @{Name = "sSamAccountName"; Expression = {($_."sSamName").ToLower()}},
    @{Name = "nPhoneNumber"; Expression = {$_."nPhoneNumber"}},
    @{Name = "sFirstName"; Expression = {$_."sFirstName"}},
    @{Name = "sLastName"; Expression = {$_."sLastName"}},
    @{Name = "sDisplayName"; Expression = {$_."sDisplayName"}},
    @{Name = "sDepartment"; Expression = {$_."sDepartment"}} | 
  Export-Csv $finOutCSV –NoTypeInformation
} 
Write-Host Finshed Writing $finOutCSV
Write-Host