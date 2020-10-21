$workingDir = Convert-Path .
$csvFinDir = $workingDir + '\final\'
$csvStgDir = $workingDir + '\stg\csv\'
$jsonStgDir = $workingDir + '\stg\json\'
$processedCsvDir = $workingDir + '\orig\'

Write-Host
Write-Host Creating working folders if they do not exist
if (-not (Test-Path -LiteralPath $csvFinDir )) {new-item $csvFinDir -itemtype directory}
if (-not (Test-Path -LiteralPath $csvStgDir)) {new-item $csvStgDir -itemtype directory}
if (-not (Test-Path -LiteralPath $jsonStgDir)) {new-item $jsonStgDir -itemtype directory}
if (-not (Test-Path -LiteralPath $processedCsvDir)) {new-item $processedCsvDir -itemtype directory}

$files = Get-ChildItem $workingDir\*.csv
foreach ($file in $files){
  $csvDoc = $file.Name
  $jsonDoc = $csvDoc -replace '.csv', '.json'
  $finOutCSV = $csvFinDir + $csvDoc
  $stgOutCSV = $csvStgDir + $csvDoc
  $stgOutJson = $jsonStgDir + $jsonDoc
  $origInputFile = $file.FullName
  
  Write-Host
  Write-Host Loading document into memory and dropping unecessary columns:  $origInputfile
  Import-Csv  $origInputFile | Select-Object message | Export-Csv $stgOutJson –NoTypeInformation

  Write-Host Converting embeded JSON found in $csvDoc MESSAGE COLUMN to valid JSON file format: $stgOutJson
  $newStr = Get-Content -raw -path $stgOutJson
  $newStr = $newStr -replace '"message"', '['
  $newStr = $newStr -replace '"{', '{'
  $newStr = $newStr -replace '}"', '}'
  $newStr = $newStr -replace '""', '"'
  $newStr = $newStr -replace '"source_json.*}}', "}"
  $newStr = $newStr -replace ',}', '},'
  $newStr = $newStr -replace '(\d\d\d\d-\d\d-\d\d)T', '$1 '
  $newStr = $newStr -replace '\.\d\d\dZ', ''
  $newStr = $newStr + ']'
  $newStr = $newStr -replace ',\r\n]', "`r`n]"
  Set-Content -path $stgOutJson -Value $newStr -Force

  Write-Host Converting document from JSON back to CSV with selected columns: $finOutCSV
  Get-Content -Raw $stgOutJson |
    ConvertFrom-Json |
    Select-Object timestamp,destination_user,destination_account,service,source_asset,source_asset_address,destination_asset,destination_asset_address,result | 
    Export-Csv $stgOutCSV -NoTypeInformation

  Write-Host Removing service and generic accounts from log. Creating final CSV document: $finOutCSV
  Import-Csv $stgOutCSV |
  Where-Object {
    ($_.destination_user -notlike '*conference*') -and
    ($_.destination_user -notlike '*index*') -and
    ($_.destination_user -notlike '*mail*') -and
    ($_.destination_user -notlike 'msol_*') -and
    ($_.destination_user -notlike 'sp_*') -and
    ($_.destination_user -notlike '*test*') -and
    ($_.destination_user -notlike 'xsv*') -and
    ($_.destination_user -ne 'csoservice') -and
    ($_.destination_user -ne 'is ecopy') -and
    ($_.destination_user -ne 'in prod') -and
    ($_.destination_user -ne 'ismainframe') -and
    ($_.destination_user -ne 'neopost') -and
    ($_.destination_user -ne 'Open _Connector') -and
    ($_.destination_user -ne 'sysops') -and
    ($_.destination_user -ne 'TH listener') -and
    ($_.destination_user -ne '') -and
    ($_.result -notlike 'FAILED*')
 } | Foreach-Object  {
          $_.'result' = '1' 
          Return $_
} | Export-Csv $finOutCSV -NoTypeInformation
Move-Item -Path $origInputFile -Destination $processedCsvDir -Force

Write-Host 
Write-Host 
}