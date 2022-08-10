Add-Type -AssemblyName System.Web


function GetXFormUrlEncodedPayloadFromHashtable($table) {

    $query_builder = New-Object System.Text.StringBuilder
    $sep = ""

    $table.Keys | ForEach-Object { 
        [void]$query_builder.Append($sep).AppendFormat("{0}={1}", $_, $table.Item($_))
        $sep = "&"
    }

    $query_builder.ToString()
}


function GetQueryStringFromHashtable($table) {

    $query_builder = New-Object System.Text.StringBuilder
    $sep = ""

    $table.Keys | ForEach-Object { 
        [void]$query_builder.Append($sep).AppendFormat("{0}={1}", $_, [System.Web.HttpUtility]::UrlEncode($table.Item($_)))
        $sep = "&"
    }

    $query_builder.ToString()
}


function GetPasswordFromSecureString([SecureString]$securedPassword) {
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securedPassword)
    $plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    return $plainPassword
}


function setupDebug ([boolean]$dbg) {

    if ($true -eq $dbg) {
        $global:DebugPreference = "Continue"
    }
    else {
        $global:DebugPreference = "SilentlyContinue"
    }

}