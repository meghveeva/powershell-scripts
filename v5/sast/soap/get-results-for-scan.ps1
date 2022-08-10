param(
    [Parameter(Mandatory = $true)]
    [hashtable]$authInfo,
    [Parameter(Mandatory = $true)]
    [int]$scanId
)

$soapPath = "/cxwebinterface/Portal/CxWebService.asmx"
$soapAction = "http://Checkmarx.com/GetResultsForScan"
$soapUrl = New-Object System.Uri $authInfo.baseUrl, $soapPath

$xmlTemplate = @"
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope 
  xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  
  xmlns:tns="http://Checkmarx.com" 
  xmlns:s1="CxDataTypes.xsd" 
  xmlns:tm="http://microsoft.com/wsdl/mime/textMatching/">
  <soap:Body>
    <GetResultsForScan 
      xmlns="http://Checkmarx.com">
      <sessionID></sessionID>
      <scanId>{0}</scanId>
    </GetResultsForScan>
  </soap:Body>
</soap:Envelope>
"@.ToString()

$body = [String]::Format($xmlTemplate, $scanId)

$response = &"$PSScriptRoot/soap-request.ps1" $authInfo $body $soapUrl $soapAction

$content = New-Object System.Xml.XmlDocument
$content.LoadXml($response.Content)

return $content.DocumentElement.SelectNodes("//*[local-name() = 'CxWSSingleResultData']")