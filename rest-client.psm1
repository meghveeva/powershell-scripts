# -----------------------------------------------------------------
# REST request body
# -----------------------------------------------------------------
Class RESTBody {

    [String] $grantType
    [String] $scope
    [String] $clientId
    [String] $clientSecret

    RESTBody(
        [String] $grantType,
        [String] $scope,
        [String] $clientId,
        [String] $clientSecret
    ) {
        $this.grantType = $grantType
        $this.scope = $scope
        $this.clientId = $clientId
        $this.clientSecret = $clientSecret
    }
}

# -----------------------------------------------------------------
# REST Client
# -----------------------------------------------------------------
Class RESTClient {

    [String] $baseUrl
    [RESTBody] $restBody

    hidden [String] $token

    # Constructs a RESTClient based on given base URL and body
    RESTClient ([String] $cxHost, [RESTBody] $restBody) {
        $this.baseUrl = $cxHost + "/cxrestapi"
        $this.restBody = $restBody
    }

    <#
    # Logins to the CxSAST REST API and returns an API token
    #>
    [bool] login ([String] $username, [String] $password) {
        [bool] $isLoginSuccessful = $False
        $body = @{
            username      = $username
            password      = $password
            grant_type    = $this.restBody.grantType
            scope         = $this.restBody.scope
            client_id     = $this.restBody.clientId
            client_secret = $this.restBody.clientSecret
        }

        [psobject] $response = $null
        try {
            $loginUrl = $this.baseUrl + "/auth/identity/connect/token"
            Write-Host "Logging into Checkmarx CxSAST..."
            $response = Invoke-RestMethod -uri $loginUrl -method POST -body $body -contenttype 'application/x-www-form-urlencoded'
        }
        catch {
            Write-Host "Could not authenticate against Checkmarx REST API. $_"
        }

        if ($response -and $response.access_token) {
            $isLoginSuccessful = $True
            # Track token internally
            $this.token = $response.token_type + " " + $response.access_token
        }

        return $isLoginSuccessful
    }

    <#
    # Invokes a given REST API
    #>
    [Object] invokeAPI ([String] $requestUri, [String] $method, [Object] $body, [int] $apiResponseTimeoutSeconds) {

        # Sanity: If not logged in, do not proceed
        if (!$this.token) {
            throw "Must execute login() first, prior to other API calls."
        }

        $headers = @{
            "Authorization" = $this.token
            "Accept"        = "application/json;v=1.0"
        }

        $response = $null

        try {
            $uri = $this.baseUrl + $requestUri
            if ($method -ieq "GET") {
                $response = Invoke-RestMethod -Uri $uri -Method $method -Headers $headers -TimeoutSec $apiResponseTimeoutSeconds
            }
            else {
                $response = Invoke-RestMethod -Uri $uri -Method $method -Headers $headers -Body $body -TimeoutSec $apiResponseTimeoutSeconds
            }
        }
        catch {
            Write-Host "REST API call failed : [$($_.exception.Message)]"
            Write-Host "Status Code: $($_.exception.Response.StatusCode)"
            Write-Host "$_"
        }

        return $response
    }
}