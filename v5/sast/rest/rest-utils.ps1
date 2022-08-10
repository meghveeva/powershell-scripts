Add-Type -AssemblyName System.Web

function GetAuthHeaders ($authInfo) {
    @{
        Authorization = $authInfo.auth_header;
    }
}

function GetRestHeadersForRequest($authInfo, $acceptType) {
    GetAuthHeaders $authInfo + @{
        Accept = $acceptType;
    }
}


function GetRestHeadersForJsonRequest($authInfo, $version) {
    $acceptType = 'application/json'
    
    if ([String]::IsNullOrEmpty($version) -ne $true) {
        $acceptType += ";v=$version"
    }

    GetRestHeadersForRequest $authInfo $acceptType
}