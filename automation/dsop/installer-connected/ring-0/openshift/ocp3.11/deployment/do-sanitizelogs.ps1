#region script variables
[string] $DeploymentEnumFile = ".\DeploymentTypeEnum.ps1"
[string] $LocalVarFile = ".\deployment.vars.usgovernment.ps1"
[string] $LogFilePath = ".\deployment-output\"
[string] $RedactString = "***"
#endregion

# ingest local var file; needed in case this runs as a standalone script
if (-not (Test-Path $LocalVarFile))
{
    throw "Cannot find $LocalVarFile.  Unable to sanitize logs."
}

if (-not (Test-Path $DeploymentEnumFile))
{
    throw "Cannot find $DeploymentEnumFile.  Unable to sanitize logs."
}

Write-Output "Scrubbing Logs."

Write-Output "Loading dependencies"
# Load dependencies
. $DeploymentEnumFile
. $LocalVarFile

# Search patterns
[array] $RegexPatterns = "((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)",
                        $ProductLine,
                        $Environment,
                        $RegionLocation 


Write-Output "Finding log files."
# read log files

$allLogFiles = Get-childitem $LogFilePath -recurse | Select-Object -expand fullname
Write-Output "Found $($allLogFiles.Count) logs to sanitize."

foreach ($logFile in $allLogFiles)
{ 
    $logContents = Get-Content $logfile
    foreach ($regex in $RegexPatterns)
    {
        $logContents = $logContents -replace $regex, $RedactString
    }
    $logContents | Set-Content $logFile
}

Write-Output "Finished sanitizing logs."
Write-Output "Please review files before exporting."