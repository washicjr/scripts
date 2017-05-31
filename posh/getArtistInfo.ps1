param([string]$a)

$baseURL = "http://www.allmusic.com/search/all/"
$searchParam = $a
$URL = $baseURL + $searchParam

Start-Process $URL