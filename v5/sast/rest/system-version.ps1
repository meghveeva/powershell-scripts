param(
    [System.Uri]$sastUrl
)

$apiPath = "/cxrestapi/system/version"
    
$apiUriBase = New-Object System.Uri $sastUrl, $apiPath
$apiUri = New-Object System.UriBuilder $apiUriBase
Write-Debug $apiUri.Uri
$response = Invoke-RestMethod -Method 'GET' -Uri $apiUri.Uri
return $response