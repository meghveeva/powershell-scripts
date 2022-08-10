Using module "./foo.psm1"
Using module "./rest-client.psm1"

$myFoo = New-Object foo
$myFoo.PrintTest()

# CxSAST REST API auth values
[String] $CX_REST_GRANT_TYPE = "password"
[String] $CX_REST_SCOPE = "sast_rest_api"
[String] $CX_REST_CLIENT_ID = "resource_owner_client"
# Constant shared secret between this client and the Checkmarx server.
[String] $CX_REST_CLIENT_SECRET = "014DF517-39D1-4453-B7B3-9930C563627C"

$config = @{
    cx = @{
        host = "http://ec2-18-191-206-110.us-east-2.compute.amazonaws.com"
        username = "leonelsanches"
        password = "Codingcraft88#"
    }
}
$cxSastRestBody = [RESTBody]::new($CX_REST_GRANT_TYPE, $CX_REST_SCOPE, $CX_REST_CLIENT_ID, $CX_REST_CLIENT_SECRET)
# Create a REST Client for CxSAST REST API
$cxSastRestClient = [RESTClient]::new($config.cx.host, $cxSastRestBody)
$cxSastRestClient.login($config.cx.username, $config.cx.password)