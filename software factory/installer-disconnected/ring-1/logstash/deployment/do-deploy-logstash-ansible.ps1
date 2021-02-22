param (
    [Parameter(Mandatory=$true)] [DeploymentType] $DeploymentType,
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $BastionHostname,
    [Parameter(Mandatory=$true)] [string] $AdminUsername,
    [Parameter(Mandatory=$true)] [string] $SshKey,
    [Parameter(Mandatory=$false)] [string] $BastionProxyUsername,
    [Parameter(Mandatory=$false)] [string] $BastionProxyIp
)

Set-LogFile "./deployment-output/deploy-logstash-ansible_$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"
Log-ScriptHeader -ScriptName $MyInvocation.MyCommand -ScriptArgs $MyInvocation.MyCommand.Parameters

$scp = "scp"
if ($IsWindows)
{
    $scp += ".exe"
}
$esacpedPath = "$($(Get-Location).Path)".Replace("\", "/")

if ($DeploymentType -eq [DeploymentType]::DisconnectedLite -or
    $DeploymentType -eq [DeploymentType]::DisconnectedStack -or
    $DeploymentType -eq [DeploymentType]::Disconnected)
{
    # need to also check if the repo is specified because we won't need the rpms if so
    $javaRpms = "$esacpedPath/deployment/java"
    $ansibleBin = "$esacpedPath/ansible/ar0-install-logstash/bin"
    Copy-Item $javaRpms $ansibleBin -Force -Recurse
}

Log-Information "Loading the compression library"
[Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem")
Log-Information "Compressing the file - $(Get-Date -Format "dddd MM/dd/yyyy HH:mm")"
$artifacts = "$($(Get-Location).Path)/ansible"
$destination = "ansible.zip"
if (Test-Path $destination)
{
    Log-Information "Removing Zip"
    Remove-Item $destination -Force
}
$zipFileLocation = "$esacpedPath/$destination"
[System.IO.Compression.ZipFile]::CreateFromDirectory($artifacts, $zipFileLocation, [System.IO.Compression.CompressionLevel]::Optimal, $false)
Log-Information "Zip file created: $zipFileLocation"

$queryIp = "publicIps"
$sshOptions = "-i `"$esacpedPath/certs/$SshKey`" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
if ($DeploymentType -eq [DeploymentType]::DisconnectedLite)
{
    $queryIp = "privateIps"
    $ssh = "ssh"
    if ($IsWindows)
    {
        $ssh += ".exe"
    }
    $cloudfitLinuxBastion = "$esacpedPath/certs/cloudfit-linux-bastion"
    $sshOptions += " -o ProxyCommand=`"$ssh -i $cloudfitLinuxBastion $BastionProxyUsername@$BastionProxyIp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -W %h:%p`""

    if (-not (Test-Path -Path $cloudfitLinuxBastion))
    {
        Read-Host "find the cloudfit-linux-bastion key and move it to: $cloudfitLinuxBastion"
    }
}

Log-Information "Getting bastion IP"
$bastionMachineName = "$BastionHostname-001v"
$bastionIpAddress=( az vm show -g $ResourceGroup -n $bastionMachineName -d --query $queryIp -o tsv )
Log-Information "Bastion IP: $bastionIpAddress"

Log-Information "sending zip to bastion"
$argList = "$sshOptions `"$esacpedPath/$destination`" $AdminUsername`@$bastionIpAddress`:$destination"
$retVal = Run-Command -Process $scp -Arguments $argList

Log-Information "sending sshkey to bastion"
$argList = "$sshOptions `"$esacpedPath/certs/$SshKey`" $AdminUsername`@$bastionIpAddress`:$SshKey"
$retVal = Run-Command -Process $scp -Arguments $argList

Log-Information "Compressing ansible rpms"
$ansibleRpms = "ansible-rpms.zip"
$ansibleRpmsPath = "$esacpedPath/deployment/ansible"
if (Test-Path $ansibleRpms)
{
    Log-Information "Removing Zip"
    Remove-Item $ansibleRpms -Force
}
[System.IO.Compression.ZipFile]::CreateFromDirectory($ansibleRpmsPath, "$esacpedPath/$ansibleRpms", [System.IO.Compression.CompressionLevel]::Optimal, $false)

Log-Information "Sending ansible rpms to bastion"
$argList = "$sshOptions `"$esacpedPath/$ansibleRpms`" $AdminUsername`@$bastionIpAddress`:$ansibleRpms"
$retVal = Run-Command -Process $scp -Arguments $argList

$scriptsPath = "$esacpedPath/extra-scripts"
if (-not (Test-Path $scriptsPath))
{
    Log-Information "Creating scripts path $scriptsPath"
    New-Item -path $scriptsPath -ItemType "directory"
}
$scriptName = "logstash-install.sh"
$fullScriptPath = "$scriptsPath/$scriptName"
if (Test-Path $fullScriptPath)
{
    Log-Information "Removing previous script $fullScriptPath"
    Remove-Item $fullScriptPath -Force -Confirm:$false
}

Log-Information "Creating script for deployment $fullScriptPath"
New-Item -Path $fullScriptPath -ItemType file -Value @"
cd /home/$AdminUsername

sudo rm -f /etc/yum.repos.d/*

unzip -o $ansibleRpms
sudo yum --nogpgcheck localinstall python-ply-3.4-11.el7.noarch.rpm -y
sudo yum --nogpgcheck localinstall python-pycparser-2.14-1.el7.noarch.rpm -y
sudo yum --nogpgcheck localinstall python-cffi-1.6.0-5.el7.x86_64.rpm -y
sudo yum --nogpgcheck localinstall python-enum34-1.0.4-1.el7.noarch.rpm -y
sudo yum --nogpgcheck localinstall python-cryptography-0.8.2-1.el7.x86_64.rpm -y
sudo yum --nogpgcheck localinstall python-idna-2.4-1.el7.noarch.rpm -y
sudo yum --nogpgcheck localinstall python2-cryptography-1.7.2-2.el7.x86_64.rpm -y
sudo yum --nogpgcheck localinstall python-paramiko-2.1.1-9.el7.noarch.rpm -y
sudo yum --nogpgcheck localinstall python-httplib2-0.9.2-1.el7.noarch.rpm -y
sudo yum --nogpgcheck localinstall python2-jmespath-0.9.0-4.el7ae.noarch.rpm -y
sudo yum --nogpgcheck localinstall python-passlib-1.6.5-2.el7.noarch.rpm -y
sudo yum --nogpgcheck localinstall sshpass-1.06-2.el7.x86_64.rpm -y
sudo yum --nogpgcheck localinstall python-babel-0.9.6-8.el7.noarch.rpm -y
sudo yum --nogpgcheck localinstall python-markupsafe-0.11-10.el7.x86_64.rpm -y
sudo yum --nogpgcheck localinstall python-jinja2-2.7.2-4.el7.noarch.rpm -y
sudo yum --nogpgcheck localinstall ansible-2.9.6-1.el7ae.noarch.rpm -y

unzip -o $destination
sudo ansible-playbook install.yml -i hosts -vv

"@
Log-Information "Encoding script for deployment $fullScriptPath"
$jsonFile = New-Base64EncodedJson -ScriptPath $scriptsPath -ScriptFileName $scriptName

Log-Information "Deploying script $fullScriptPath"
New-AzureLinuxExtension -ResourceGroup $ResourceGroup -VmName $bastionMachineName -JsonFile $jsonFile

Log-Information "Deployment complete. Showing the log file."
Start-Sleep 10

$argList = "$sshOptions $AdminUsername`@$bastionIpAddress `"sudo cat /var/lib/waagent/custom-script/download/0/stdout`""
$retVal = Run-Command -Process "ssh" -Arguments $argList

# Once the second command has ben executed, 
# check the logs for a logstash log that shows 
# running pipelines count equal to the number of pipelines enabled 
# in the ansible script. 
# If the count does not match, 
# there is a problem with the pipeline. 
# Also, verify that there is a logstash log that 
# shows an established connection to elasticsearch.

Log-ScriptEnd





# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUIpb37dfQ5rjb00uuGISm2pqc
# BjGgggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBQHoHXMyDGi4PGp/y7NQwT4fDttcDANBgkqhkiG
# 9w0BAQEFAASCAgBM+/Jff9TtDxG/pqz9TCSViIOT+LBZzNEr512J7JUrfOim7Rbt
# NOCKNcxh36r5zleNk+uwxJHczgnnLHupXaVGDcv1ELZTsD/zpVMJZdMWPCnNxoG8
# ZCIhQbfw27rQsIjt9Jp30bc916Zr0wYIWbWLNwfk1kQwjYV+cDHa+gzBjGu1sQGm
# XMDNOMK9SqterkOVUIM8qFewmndK/D4nKV68ZgcMMkb1g9hWHwPJmIzCmKT+Rf1t
# r/V++w09hVeOgPDVjwzLEgysMenTso4F3S/U9bPRwojODdG6AwW2DOaoev2pq0gP
# 9+hAoFnBeEg1I2A1fFFSNHSXR4kb90hhR/7T0EPLdU0nRJ7kPN5ThVSigD2MnU/9
# wPK9r0vTX53J7g9OA+lPgWKyVhCpkcM/DKtd2RgKIv6/QRXNQbGeYXk/D7ZNq1U/
# PCY4YP7PBU27gwaQwUWPdNbtYzCc2JcFoPqZHAgo0lS+K2YAr1M+7raFkoa/hXOE
# W/aEsEqI71bGAxcMNTjNi8XOwPJHqWbBTF4fm6yQDomJNxKVfFClJNVElMDO8vdP
# 26O1DMKDHlzY3CkPiJVhYDjtp4Xv4O3mFyYffjPP3eZ/w6w6fTrMwDMaUkjmhL7u
# HK56miGHfUAo/BVQi0gqNoJLI+CI6zOG5Hu/jUJ+3IkLH1qW2wCbCoTS6w==
# SIG # End signature block
