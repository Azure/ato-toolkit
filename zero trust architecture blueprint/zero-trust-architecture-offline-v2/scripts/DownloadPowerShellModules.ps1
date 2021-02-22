. "$PSScriptRoot/RequiredModules.ps1"

$requiredModules = Get-RequiredModules

# Install the required modules
foreach($requiredModule in $requiredModules) {
    Install-module -Name $requiredModule.ModuleName -RequiredVersion $requiredModule.ModuleVersion -Force
}