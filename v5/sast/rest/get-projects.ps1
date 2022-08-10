param(
    [Parameter(Mandatory = $true)]
    [hashtable]$authInfo,
    [string]$projectId
)

. "$PSScriptRoot/rest-utils.ps1"

$path = "/cxrestapi/projects"

if ([String]::IsNullOrEmpty($projectId) -ne $true) {
    $path += "/$projectId"
}

$requestUrl = New-Object System.Uri $authInfo.baseUrl, $path

Write-Debug "Projects API URL: $requestUrl"

$headers = GetRestHeadersForJsonRequest($authInfo, "2.0")

Invoke-RestMethod -Method 'Get' -Uri $requestUrl -Headers $headers