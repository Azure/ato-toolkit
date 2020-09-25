$VariableFile = ".\deployment.vars.ps1"
$CommonLibraryVersionRequirement = "0.0.1"

# Odd work-around to load modules into memory
Get-Command Log-Information -ErrorAction SilentlyContinue | Out-Null

if (-not (Test-Path $VariableFile))
{
    Throw "Variable file, $VariableFile, not found.  Please double check the path"
    exit
}

$installedModule = Get-Module -Name CloudFit.Dsop.Common
if ($installedModule)
{
    Write-Output "Found CloudFit.Dsop.Common module. Checking version requirements."
    if ($installedModule.Version -ge $CommonLibraryVersionRequirement)
    {
        Write-Output "Found version $($installedModule.Version)"
    }
    else 
    {
        throw "$($installedModule.Version) is less than minimum required version: $CommandLibraryVersionRequirement"
    }
}
else 
{
    throw "Cannot find CloudFit.Dsop.Common library.  Cannot continue."
}

$VariableFile = Get-ChildItem $VariableFile

$previousFgColor = $host.ui.RawUI.ForegroundColor
$host.ui.RawUI.ForegroundColor = "DarkGreen"

Write-Output ""
Write-Output "Loading Variables from var file"
. $VariableFile
Write-Output ""
Write-Output "The variables that will be used are..."
Write-Output ""
Start-Sleep -Seconds 3
$DepArgs.GetEnumerator() | Sort-Object Name

$host.ui.RawUI.ForegroundColor = $previousFgColor
Write-Output ""
Write-Output ""
Write-Output "Please review the varaibles above in Green. If they are not want you want please, change them in deployment.vars.ps1 file."
$Continue = Read-Host -Prompt 'Do you want to continue?[y/n]'
$Continue = $Continue.ToLower()
if ($Continue -eq 'y' -Or $Continue -eq 'yes')
{
    Write-Output ""
    Write-Output "Starting Setup. Sit back 🪑, get coffee ☕️ (or tea 🍵), and Godspeed 🚀"
    Write-Output ""
}
else
{
    Write-Output ""
    Write-Output "Exiting script so deployment.vars.ps1 can be updated. Once updated run install.ps1"
    Write-Output ""
    return
}

$IsExpectedPwshVersion = $PSVersionTable.PSVersion.Major -eq "7"

$PowershellCorePath = ".\powershell-core\install"
if (Test-Path -Path $PowershellCorePath) {
    Remove-Item -Path $PowershellCorePath -Recurse -Force
}

if ($IsWindows)
{
    if (-not $IsExpectedPwshVersion)
    {
        Write-Output ""
        Write-Output "Unzipping Powershell Core"
        New-Item -path $PowershellCorePath -ItemType "directory"
        Expand-Archive ".\powershell-core\Windows\PowershellCore.zip" $PowershellCorePath
        Write-Output "Done Unzipping Powershell Core"
        Start-Sleep -Seconds 5
    }
    else
    {
        Write-Output "Already running the expected Powershell Core version"
    }
}
elseif ($IsMacOS) {
    Write-Output "Powershell core for macOS is already installed"
}
elseif ($IsLinux) {
    Write-Output "Powershell core for linux is already installed"
}
else {
    Write-Error "you're not supported. also, how did you get here?"
    throw
}

Write-Output ""
Write-Output "Installing Azure CLI"

if ($PSVersionTable.PSVersion.Major -le "5")
{
    ./do-verify-azure-cli.ps1 $PowershellCorePath
}
elseif ($PSVersionTable.PSVersion.Major -ge "6")
{
    if ($IsWindows)
    {
        ./do-verify-azure-cli.ps1 $PowershellCorePath
    }
    elseif ($IsMacOS) {
        Write-Output "MacOS is the Best OS!"
        # Write-Error "not implemented, but really need to find out what we want to do here"
        # throw
        Write-Output "Going to Bash Mac"
        /bin/bash ~/ocp-install-artifacts/do-verify-azure-cli-mac.sh
        # This needs internet access to run
    }
    elseif ($IsLinux) {
        Write-Output "Going to Bash"
        bash ./do-verify-azure-cli-linux.sh
        #bash -c "sudo yum check-update"
        #bash -c "sudo yum reinstall -y -q python gcc python3-devel libffi-devel openssl-devel curl"
        #bash -c "sudo ln -s /usr/bin/python3 /usr/bin/python"
        #curl https://azurecliprod.blob.core.windows.net/install | bash
        # This needs internet access to run
    }
    else {
        Write-Error "you're not supported. also, how did you get here?"
        throw
    }
}
else {
    Write-Error "you're not supported. also, how did you get here?"
    throw
}

Write-Output ""
Write-Output "Preparing for deployment"
$DeploymentOutput = "./deployment-output/"
if (Test-Path -Path $DeploymentOutput) {
    Write-Output "Deployment output already exists. Removing $DeploymentOutput"
    Remove-Item -Path $DeploymentOutput -Recurse -Force | out-null
}
New-Item -path $DeploymentOutput -ItemType "directory" | out-null

if ($PSVersionTable.PSVersion.Major -le "5")
{
    Write-Output "Starting Deployment in PowerShell Core in another window"
    Start-Process -FilePath "$PowershellCorePath\pwsh.exe" -Wait -ArgumentList {-command . $VariableFile; .\do-deployment.ps1 @DepArgs | Tee-Object -FilePath ./deployment-output/do-deployment.txt }
}
elseif ($PSVersionTable.PSVersion.Major -ge "6")
{
    if ($IsExpectedPwshVersion)
    {
        Write-Output "Starting Deployment"
        ./do-deployment.ps1 @DepArgs | Tee-Object -FilePath ./deployment-output/do-deployment.txt
    }
    elseif ($IsWindows)
    {
        Write-Output "Starting Deployment in PowerShell Core in another window"
        Start-Process -FilePath "$PowershellCorePath\pwsh.exe" -Wait -ArgumentList {-command . $VariableFile; .\do-deployment.ps1 @DepArgs | Tee-Object -FilePath ./deployment-output/do-deployment.txt }
    }
}

Write-Output ""
Write-Output "Deployment Finished"
Write-Output ""







# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUlDkoq1hPNCLx3OVc6K7bDKw9
# LpegggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
# AQsFADAYMRYwFAYDVQQDDA1KZXJlbXlPbGFjaGVhMB4XDTIwMDgzMTIxMTUxMFoX
# DTIxMDgzMTIxMjQ1OVowGDEWMBQGA1UEAwwNSmVyZW15T2xhY2hlYTCCAiIwDQYJ
# KoZIhvcNAQEBBQADggIPADCCAgoCggIBAJu5Y9YhmKGhwU+/kj7dsj1OvrliwUCe
# kdPsfdTAPh9peuKKF+ye8U3l3UT8luf5nCYlG/eKe5YxI3pBYhfZwy7yKZpsx5Tn
# ST7t38owgktj0W6YYfoDgfR4zwLtRk3taNWiZeyHu/UhszNs4d3L9wl6Ei/otfRt
# jyz1UO40361YWriD43jbnsCLjVpIfiwW2LH1H9cVoCLnbMZ217rpVxDiTlFPBGeW
# Bk2pxPn5Z2Ly1j6q/SlliEOKDXXrPQZz+sSc3L/ZXBl7D2/ua4+xJmDw/XE1GUBA
# Pldde/IHAzmp6lHHgdQLjCaks//cucDeYBzVTD8XZo8T9WIWU6o6I6SRzGKSIHcX
# SoKVy1hjaW14wJHImw/nlnCgDLMcBBpnRFo6UHAAUzpWlcgqCC+johdXVSa62+hP
# bLwgqfm6uty0rJRwkhbm1Qi0w6HOUZiIkBIz/5Q83t9nLhWL+uWndKIe9BiVfl1f
# x0p5Ax5hzWD5PV1rjrXSQLpL9PRLKcEAy7EoXa/5VGGKSAOrUZdey39vL3AOct0w
# i3vh49DTfWXuxxHbiWz2VEIZqNWQu/rIi9uiCvzaFUo19DwSZrv1ac+OOmZsloqB
# yDugGWFmxiQjEFWtGxEqwDXPDsJE/gKEPvUha37YCI6iQTtcwiwJpnPfGWODqUHH
# 0/NuToVp4ci5AgMBAAGjRjBEMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
# BgEFBQcDAzAdBgNVHQ4EFgQU16Rx2qHCuXNeExsbMFbSE/Io0NYwDQYJKoZIhvcN
# AQELBQADggIBAG+8jfz9QCzSUK5WGIW0gnEK3rN8oxmSax7C6HJfGPMLXHBEWtBt
# ZCeD8XXkTMu8fhvQDseGgxJ4NmRR+s1d8YtnVgtDbEhO/FHSpOPonTvIx13t37Uz
# Tbvq0ZLeB6z55noAOIhXBs9or1pzxio71sDNfYpIB6s41X5/m1UZk8toxcPDqQGL
# Kg3C3xqgg9+2kQ16flYKvZh2UoK5Y0EyEb8rMc+6AFH3GgcP7yoUsUENP9vkLbXm
# 2VRMIzd/Tee7oKQK50K1GxtlWLUUjuAUMCQh+9K/JyAUro9jfMNHCGcPTaayXBvl
# kaCOjb1IrKgtsS/c2p7mgbssdFHHGPBlbggogGFxYof+6SDI2YB8AqT3RYJdJH4c
# 6StsYUka1faCYcZfz+DIm2+avSCKdliOb285WT8yqoh7P2qN6bLt2au0IsfUKR+d
# EgSL3waCmT+xUI6BI6mpnSjgA0/Hr6I/wkxHu/hk0G0q4OdBpXpSzCzurKPdQWB+
# K/PaQSCyEGk4IGqFrHMx863mtW+mlm6jCM/5/b5ugAmF4XoNkVzdmfFhepqq4h0v
# ioKE+1sLxgq2lFtKAZMjpJB7HZ9KVQcb/hSYlgms/mG6P+4GIhf7ZfvlI2LsCdbV
# 42kEAfDVDuHcCqWyJr43vm+vY6xzjDRnNmaqVJgH1sZO0kwajDOKkm/JMYICzTCC
# AskCAQEwLDAYMRYwFAYDVQQDDA1KZXJlbXlPbGFjaGVhAhAVrGjoMQw2rkF3eYcz
# j/kHMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqG
# SIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3
# AgEVMCMGCSqGSIb3DQEJBDEWBBRL5DiFjLuHi3x3xLaAYzPyDzQeXDANBgkqhkiG
# 9w0BAQEFAASCAgAtha8uwqelqy7I3cTZYVervER4OEg+oOUpLxtdp80QtHEzvgDa
# 1vDPQmW/HVuh06cT1Kwe+0p+lTSkhRrnmlp95ZAyK8kTBZfjc5vh1W6YQagMzUi4
# mHfxPqdr1LVcn2N5RyApQ/K1uJJpPxfaw9mrl6JiuKM8z1lGSJNWeVWqDpbTkOxG
# PEvfmov/o38bQKefAQ2toV/5oVmJzXJtFDZYobgjBdY+9KUnMTQIyIn9a3XvdLia
# K2tmexix1ee44iyATjiUfaGfozFwwklkEeOcfI+ERwus8lpBPjBp9+Ykrd1r1MfC
# 8A8xkcbVbkLrqg7kqXpOGyJdqTSejswIqMxTQ6cjx67DnTEH3z+gdI/RsyRqzgxZ
# BIDjJ82e/GsSJeYJYGn+e1/br/EeS1ISL18c5x5NW7CN1+7Fm3j30kqLnd1uIprL
# tLfZSrnyKrslrXqGbSYFV16e1CgYHuvqOGeEWOnNbF9qlWMyynV/JHINc6XJBqpZ
# TPdKebOc+kOjumD1tdqNDTu2fuhLh6ikgScz/R/4FFiKUaPHoKW+iSopLD/kNsSk
# Tb8f5neXmvf1/PqtcJLfVCwH5scv1XYzdG54IHRc6JsazM/K2vmKvYTzwU2buldM
# jZmwER0WMq6k4KZt8i8TVZzuJQmy2QM+n25YAr6MOP89oWFPx38Z89qVsg==
# SIG # End signature block
