param(
    [Parameter(Mandatory = $true)]
    [hashtable]$authInfo,
    [Parameter(Mandatory = $true)]
    [string]$projectId,
    [string]$scanStatus = "Finished",
    [string]$last = "1"
)

. "$PSScriptRoot/rest-utils.ps1"

$requestUrl = New-Object System.Uri $authInfo.baseUrl, "/cxrestapi/sast/scans"
$requestUrl = New-Object System.UriBuilder $requestUrl

$requestUrl.Query = GetQueryStringFromHashtable @{
    projectId  = $projectId;
    scanStatus = $scanStatus;
    last       = $last;
}

Write-Debug "Scans API URL: $requestUrl"

$headers = GetRestHeadersForJsonRequest($authInfo)

Invoke-RestMethod -Method 'Get' -Uri $requestUrl.Uri -Headers $headers

