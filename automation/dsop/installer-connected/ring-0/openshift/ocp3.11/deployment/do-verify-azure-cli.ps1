param (
    [Parameter(Mandatory=$true)] [string] $PowershellCorePath
)

[string] $MinimumRequiredVersion = "2.0.76"
Write-Output "Checking installed Azure CLI version"
if (Test-Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Microsoft Azure CLI")
{
    $installedVersion = (Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Microsoft Azure CLI").Version
    if ($installedVersion -ge $MinimumRequiredVersion)
    {
        Write-Output "Azure CLI version $installedVersion found and is above required version $MinimumRequiredVersion"
        Write-Output "Continuing installation."
    }
    else
    {
        Write-Output "Found existing installtion, but installed version [$installedVersion] is below minimum required version [$MinimumRequiredVersion]"
        Write-Error "Please update to az cli to a supported version."
        throw
    }
}
else
{
    Write-Error "No existing Azure CLI instance found. Please install az cli."
    throw
}
