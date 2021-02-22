param (
    [string] $LogFile,
    [string] $Arguments
)

if (-not $LogFile)
{
    $substring = 35
    if ($Arguments.Length -lt $substring)
    {
        $substring = $Arguments.Length
    }
    $LogFile = "./deployment-output/" + $Arguments.Substring(0, $substring).Replace(" ", "-") + "_$(Get-Date -format MM-dd-yyyy-hhmmss).log"
}

Write-Output "**** LOGFILE $LogFile ****"
# Import common files
$importFiles = Get-ChildItem ".\Common\*.ps1"
if ($importFiles.Count -gt 0) {
    foreach ($file in $importFiles) {
        Write-Host "Importing common library [$($file.BaseName)]"
        . $file.FullName
    }
} else {
    Write-Host "This script requires additional modules to be loaded.  Could not find any." -ForegroundColor Red
    Write-Host "Exiting script." -ForegroundColor Red
    exit(1)
}

Log-ScriptHeader -ScriptName $MyInvocation.MyCommand `
    -LogFile $LogFile `
    -ScriptArgs $MyInvocation.MyCommand.Parameters

$proc = "az"
$retVal = Run-Command -Process $proc -Arguments $Arguments

Log-ScriptEnd
