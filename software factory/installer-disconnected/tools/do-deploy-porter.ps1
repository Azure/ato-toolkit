if ($PSVersionTable.PSVersion.Major -lt "6")
{
    Write-Output "Powershell version 7 is required"
    exit
}

$baseDirectory = "$($(Get-Location).Path)"
$configFile = "porter.deployment.vars.jsonc"

try
{
    $jsonConfig = Get-Content "$baseDirectory/$configFile" -ErrorAction Stop | ConvertFrom-Json
}
catch 
{
    throw "Cannot find $baseDirectory/$configFile. Cannot proceed with script."
}

Set-LogFile -LogFile "$($jsonConfig.deploymentConfig.logFile)"
Log-ScriptHeader -ScriptName $MyInvocation.MyCommand -ScriptArgs $MyInvocation.MyCommand.Parameters

$scp = "scp"
if ($IsWindows)
{
    $scp += ".exe"
}

$escapedPath = "$($(Get-Location).Path)".Replace("\", "/")

$queryIp = "publicIps"
$sshOptions = "-i `"$escapedPath/../ring-0/ocp-3.11/deployment/certs/$($jsonConfig.deploymentConfig.sshKey)`" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
if ($jsonConfig.deploymentConfig.deploymentType -eq [DeploymentType]::DisconnectedLite)
{
    $queryIp = "privateIps"
    $ssh = "ssh"
    if ($IsWindows)
    {
        $ssh += ".exe"
    }
    $cloudfitLinuxBastionCert = "$escapedPath/certs/cloudfit-linux-bastion"
    $sshOptions += " -o ProxyCommand=`"$ssh -i $cloudfitLinuxBastionCert $($jsonConfig.deploymentConfig.bastionProxyUsername)$($jsonConfig.deploymentConfig.bastionProxyIp) -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -W %h:%p`""

    if (-not (Test-Path -Path $cloudfitLinuxBastion))
    {
        Read-Host "find the cloudfit-linux-bastion key and move it to: $cloudfitLinuxBastion"
    }
}

Log-Information "Getting bastion IP"
$bastionMachineName = "$($jsonConfig.deploymentConfig.bastionHostname)"
$bastionIpAddress = ( az vm show -g "$($jsonConfig.deploymentConfig.resourceGroup)" -n $bastionMachineName -d --query $queryIp -o tsv )

Log-Information "Compressing Porter binaries"
$porterZip = "porter.zip"

if (Test-Path $porterZip)
{
    Log-Information "Removing Zip"
    Remove-Item $porterZip -Force
}

Log-Information "Loading the compression library"
[Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem")

# Fix Pathing issues:
$porterBinary = "porter"
if ($jsonConfig.deploymentConfig.bastionOS -eq "windows")
    {
        $porterBinary += ".exe"
    }

$porterPath = "$escapedPath/porter/$($jsonConfig.deploymentConfig.bastionOS)/"

[System.IO.Compression.ZipFile]::CreateFromDirectory("$porterPath", "$escapedPath/$porterZip", [System.IO.Compression.CompressionLevel]::Optimal, $false)

Log-Information "Sending zip to bastion"
$argList = "$sshOptions `"$escapedPath/$porterZip`" $($jsonConfig.deploymentConfig.adminUsername)`@$bastionIpAddress`:$porterZip"
$retVal = Run-Command -Process $scp -Arguments $argList

Log-Information "Creating script for porter extraction and chmods"

$porterScript = "porter.sh"
$porterScriptPath = "$escapedPath/$porterScript"

if (Test-Path $porterScriptPath)
{
    Log-Information "Removing script"
    Remove-Item $porterScriptPath -Force
}

New-Item -Path $porterScriptPath -ItemType file -Value @"
cd /home/$($jsonConfig.deploymentConfig.adminUsername)

unzip -o $porterZip -d ./.porter/

chmod +x ./.porter/ -R

sudo ln -s /home/$($jsonConfig.deploymentConfig.adminUsername)/.porter/porter /usr/bin/

"@

Log-Information "Encoding script for deployment $porterScript"
$jsonFile = New-Base64EncodedJson -ScriptPath $escapedPath -ScriptFileName $porterScript

Log-Information "Deploying script $porterScript"
New-AzureLinuxExtension -ResourceGroup "$($jsonConfig.deploymentConfig.resourceGroup)" -VmName $bastionMachineName -JsonFile $jsonFile

Log-Information "Deployment complete. Showing the log file."
Start-Sleep 10

$argList = "$sshOptions $($jsonConfig.deploymentConfig.adminUsername)`@$bastionIpAddress `"sudo cat /var/lib/waagent/custom-script/download/0/stdout`""
$retVal = Run-Command -Process "ssh" -Arguments $argList

Log-ScriptEnd






# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUijFwepM7BJHx+YOK7SSBtLvT
# 5uSgggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBRIqa5UWHHUM3xWDoaLaPZ2uRpYEDANBgkqhkiG
# 9w0BAQEFAASCAgCavVjuKP0xt9NZ36bG6hl/+RHsA6l6yBIz79EwesxnCzBdwaBg
# P/SOelRYOUQeZ9LD4+Fowlj2/Nh0OiLX1B+RZO/aDWuKZ/Yhb/Eym6eMPrqaGlOX
# hAk05CdHwIOgRt6yTPcWYPco9jx2qGlp6SBgH+UzPV8J5O4w2bGDgTajjoNIRsRL
# rvD8qn3kdNlqfHalxPnRIxcezh5wITEB2fObDOkKirM/FAwr6xbuGaY/OCGr74mi
# hOFiOElEIYlNXSel43xWVnvF8y35wW53H807ks0oCra0DM3MnWwWaNmQ5tsPlQ35
# WVo3w3UXln5RqNHbWm2kMbY/oUTBJ2vH+znNbIE+xE7yTphqWRyV2x8VfGbnRDII
# 4ezAIUwjw+iTOpjcbtIkHfW0QSzIB+nZCZD0XCYGg7GrR2T3zLyYP6xNiRO2cbXH
# lLdjRgrKV6zHcK4A02lC48hU5hHYNYHpKbERknrZREVnhcy1qs7r+jm/2+2Sxf1W
# rFTz2rVjEskvgESOzlxWrhkEPqNnxerhkzbLGBETjcUKdmVgOHGihorv2osjjZcC
# Yi8I3B7TdxqPVHWndtx0VLxo1aoPHSlKgGnEKKuQIFTnNfs2te9hB1gHi4zd3CfU
# tiOvA7w5zvKq8c4Fv1kn/cYw9Uebb8jYK1nfppHnSbIR0eT99VrC22Q7aA==
# SIG # End signature block
