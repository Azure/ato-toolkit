param (
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $BastionMachineName,
    [string] $RawSshKey = $(Get-Content -path "./certs/$SshKey" -raw)
)

$scriptsPath = "$($(Get-Location).Path)/Ring-0/extra-scripts"
if (-not (Test-Path $scriptsPath))
{
    New-Item -Path $scriptsPath -ItemType "directory"
}

$rawSshScriptPath = "$scriptsPath/rawssh.sh"
if (Test-Path $rawSshScriptPath)
{
    Remove-Item $rawSshScriptPath -Force -Confirm:$false
}

New-Item -Path $rawSshScriptPath -ItemType file -Value @"
runuser -l ocpadmin -c "cat >> ~/.ssh/id_rsa << EOF
$RawSshKey
EOF"
runuser -l ocpadmin -c "chmod 600 ~/.ssh/id_rsa*"
"@
$jsonFile = New-Base64EncodedJson -ScriptPath $scriptsPath -ScriptFileName "rawssh.sh"

New-AzureLinuxExtension -ResourceGroup $ResourceGroup -VmName $BastionMachineName -JsonFile $jsonFile
