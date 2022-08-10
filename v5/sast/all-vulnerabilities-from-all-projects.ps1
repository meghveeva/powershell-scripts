<#

    .SYNOPSIS
        This script iterates projects in the SAST system and generates a CSV report with all vulnerabilities from each last scan.

    .DESCRIPTION
        The script first fetches all the projects, then it gets the last scan for each project. With the last scan ID, it gets all the vulnerabilities.

        To perform this operation, it requires authenticating in REST and SOAP, with different JWT Tokens.

        This script is intended to work for SAST versions 9.3 or newer.

    .PARAMETER sastUrl
        The URL to the CxSAST instance.

    .PARAMETER username
        The name of the user in the CxSAST system.

    .PARAMETER password
        The password for the user in the CxSAST system.

    .PARAMETER outputFile
        The output CSV file. Default: all-vulnerabilities-from-all-projects.csv

    .PARAMETER dbg
        (Optional Flag) Runs in debug mode and prints verbose information to the screen while processing. 

#>

param(
    [Parameter(Mandatory = $true)]
    [System.Uri]$sastUrl,
    [Parameter(Mandatory = $true)]
    [String]$username,
    [Parameter(Mandatory = $true)]
    [SecureString]$password,
    [String]$outputFile = "all-vulnerabilities-from-all-projects.csv",
    [Switch]$dbg
)

. "./utils.ps1"

setupDebug($dbg.IsPresent)

$restAuthInfo = & "$PSScriptRoot/rest/auth.ps1" $sastUrl $username $password -dbg:$dbg.IsPresent
$soapAuthInfo = & "$PSScriptRoot/soap/auth.ps1" $sastUrl $username $password -dbg:$dbg.IsPresent

$allProjects = & "$PSScriptRoot/rest/get-projects.ps1" $restAuthInfo

$projectsLatestScans = New-Object 'System.Collections.Generic.Dictionary[string, int]'
$allProjects | ForEach-Object {
    $latestScan = & "$PSScriptRoot/rest/get-scans.ps1" $restAuthInfo $_.id
    $projectsLatestScans.Add($_.name, $latestScan.id)
}

$allResults = @()
$projectsLatestScans.Keys | ForEach-Object {
    $actualProject = $_

    try { 
        $scanResults = & "$PSScriptRoot/soap/get-results-for-scan.ps1" $soapAuthInfo $projectsLatestScans[$_]
        $scanResults | ForEach-Object {
            $allResults += New-Object -Type PSObject -Property @{
                "Project" = $actualProject
                "QueryId" = $_.QueryId
                "PathId" = $_.PathId
                "SourceFolder" =$_.SourceFolder
                "SourceFile" = $_.SourceFile
                "SourceLine" = $_.SourceLine
                "SourceObject" = $_.SourceObject
                "DestFolder" = $_.DestFolder
                "DestFile" = $_.DestFile
                "DestLine" = $_.DestLine
                "NumberOfNodes" = $_.NumberOfNodes
                "DestObject" = $_.DestObject
                "Comment" = $_.Comment
                "State" = $_.State
                "Severity" = $_.Severity
                "AssignedUser" = $_.AssignedUser
                "ConfidenceLevel" = $_.ConfidenceLevel
                "ResultStatus" = $_.ResultStatus
                "IssueTicketID" = $_.IssueTicketID
                "QueryVersionCode" = $_.QueryVersionCode
            }
        }
    }
    catch { Write-Output "Failed for Project" + $actualProject + ". Continuing..." }
}

$allResults | Export-Csv -Path $outputFile -NoType