param(
    [Parameter(Mandatory = $true)]
    [hashtable]$authInfo,
    [Parameter(Mandatory = $true)]
    [string]$payload,
    [Parameter(Mandatory = $true)]
    [string]$urlSuffix,
    [Parameter(Mandatory = $true)]
    [string]$soapAction
)

$soapUrl = New-Object System.Uri $authInfo.baseUrl, $urlSuffix

$headers = @{
    SOAPAction = $soapAction;
    Authorization = $authInfo.auth_header;
}

Write-Debug "SOAP Request: action [$soapAction] at [$soapUrl]"
Write-Debug $headers
Write-Debug $payload

$response = Invoke-WebRequest -ContentType "text/xml" -Method "Post" -Headers $headers -Body $payload -Uri $soapUrl

if (200 -eq $response.StatusCode) {
    $content = New-Object System.Xml.XmlDocument
    $content.LoadXml($response.Content)

    if ($true -eq [Convert]::ToBoolean($content.DocumentElement.SelectSingleNode("//*[local-name() = 'IsSuccesfull']").InnerText)) {
        return $response
    }
    else {
        $msg = $content.DocumentElement.SelectSingleNode("//*[local-name() = 'ErrorMessage']").InnerText
        throw "SOAP Request failed: $msg"
    }
}
else {
    throw "Error invoking SOAP method [$($headers.SOAPAction)] at [$soapUrl]: response code is $($response.StatusCode)"
}
