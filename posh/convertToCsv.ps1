$filePath = Get-ChildItem -Path "D:\users\Clarence\Downloads\data\json"
ForEach($i in $filePath){
    $nam =  $i.Name
    $dir = $i.Directory
    $fnam = $i.fullname
    $csv = $nam -replace ".json", ".csv"
        
    Write-Host $nam
    Write-Host $dir
    
    Get-Content -Path $fnam | ConvertFrom-json | Export-CSV -Path D:\users\Clarence\Downloads\data\csv\$csv
}