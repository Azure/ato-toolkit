. "$PSScriptRoot/RequiredModules.ps1"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

$requiredModules = Get-RequiredModules

# Install the required modules
foreach($requiredModule in $requiredModules) {
    Install-module -Name $requiredModule.ModuleName -RequiredVersion $requiredModule.ModuleVersion -Force
}

# Increase the MaxE
Set-Item -Path WSMan:\localhost\MaxEnvelopeSizekb -Value 8192
