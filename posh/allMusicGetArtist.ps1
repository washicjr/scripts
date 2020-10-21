Param(
    [parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [String]
    $artist
)

$baseURL = "http://www.allmusic.com/search/all/"
$searchParam = [System.Web.HttpUtility]::UrlEncode($artist) 
$URL = $baseURL + $searchParam

Start-Process $URL
