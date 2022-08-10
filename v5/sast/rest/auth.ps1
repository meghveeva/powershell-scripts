param(
    [Parameter(Mandatory = $true)]
    [System.Uri]$sastUrl,
    [Parameter(Mandatory = $true)]
    [String]$username,
    [Parameter(Mandatory = $true)]
    [SecureString]$password,
    [Switch]$dbg
)

. "$PSScriptRoot/../utils.ps1"

# setupDebug($true)

Write-Debug "Executing new login"
$session = @{}

$queryElements = @{
    username      = $username;
    password      = $password;
    grant_type    = "password";
    client_secret = "014DF517-39D1-4453-B7B3-9930C563627C";
}

$systemVersion = & "$PSScriptRoot/system-version.ps1" $sastUrl
$sastInfo = @{
    v9 = $systemVersion.version[0] -eq "9"
}

if ($true -eq $sastInfo.v9) {
    $queryElements.scope = "sast_api"
    $queryElements.client_id = "resource_owner_sast_client"
}
else {
    $queryElements.scope = "sast_rest_api"
    $queryElements.client_id = "resource_owner_client"
}

$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
$plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
$queryElements.password = $plainPassword

$apiPath = "/cxrestapi/auth/identity/connect/token"
$apiUriBase = New-Object System.Uri $sastUrl, $apiPath
$apiUri = New-Object System.UriBuilder $apiUriBase

$query = GetXFormUrlEncodedPayloadFromHashtable $queryElements

$session.authUri  = $apiUri.Uri;
$session.authBody = $query
$session.username = $username
$session.sastInfo = $sastInfo
$session.baseUrl = $sastUrl

$resp = Invoke-RestMethod -Method 'Post' -Uri $session.authUri -ContentType "application/x-www-form-urlencoded" -Body $session.authBody

$session.auth_header = [String]::Format("{0} {1}", $resp.token_type, $resp.access_token);
$session.expires_at  = $(Get-Date).AddSeconds($resp.expires_in);

return $session