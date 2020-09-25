param (
    [Parameter(Mandatory=$true)] [string] $VariableFile
)

if (-not (Test-Path $VariableFile))
{
    Throw "Variable file, $VariableFile, not found.  Please double check the path"
    exit
}

$VariableFile = Get-ChildItem $VariableFile

$previousFgColor = $host.ui.RawUI.ForegroundColor
$host.ui.RawUI.ForegroundColor = "DarkGreen"

Write-Output ""
Write-Output "Loading Variables from var file"
./DeploymentTypeEnum.ps1
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

if ($Continue -eq 'y')
{
    Write-Output ""
    Write-Output "Starting Setup. Sit back 🪑, get coffee ☕️ (or tea 🍵), and Godspeed 🚀"
    Write-Output ""
}
if ($Continue -eq 'n')
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
        Write-Error "Please use the latest version of powershell."
        throw
    }
}
elseif ($IsMacOS) {
    Write-Host "Powershell core for macOS is already installed"
}
elseif ($IsLinux) {
    Write-Host "Powershell core for linux is already installed"
}
else {
    Write-Error "you're not supported. also, how did you get here?"
    throw
}

Write-Output ""
Write-Output "Installing Azure CLI"

if ($IsWindows)
{
    ./do-verify-azure-cli.ps1 $PowershellCorePath
}

Write-Output ""
Write-Output "Preparing for deployment"
$DeploymentOutput = "./deployment-output/"
if (Test-Path -Path $DeploymentOutput) {
    Write-Output "Deployment output already exists. Removing $DeploymentOutput"
    Remove-Item -Path $DeploymentOutput -Recurse -Force
}
New-Item -path $DeploymentOutput -ItemType "directory"

Write-Output "Starting Deployment"
./DeploymentTypeEnum.ps1
. $VariableFile
./do-deployment.ps1 @DepArgs | Tee-Object -FilePath ./deployment-output/do-deployment.txt

Write-Output ""
Write-Output "Deployment Finished"
Write-Output ""
