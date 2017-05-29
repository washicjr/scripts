param([string]$a)

$baseURL = "http://www.allmusic.com/search/all/"
$searchParam = $a -replace " ", "%20"
$URL = $baseURL + $searchParam

Start-Process $URL
