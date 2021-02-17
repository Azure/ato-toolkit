. "$PSScriptRoot\artifacts\RequiredModules.ps1"
$srcPath = "$PSScriptRoot\src"

$requiredModules = Get-RequiredModules
foreach ($requiredModule in $requiredModules) {
    Write-Host "Downloading "$($requiredModule.ModuleName)" to $srcPath folder..."
    Find-Module -Name "$($requiredModule.ModuleName)" -RequiredVersion "$($requiredModule.ModuleVersion)" | Save-Module -Path $srcPath
}

Write-Host "Deleting VMWare modules..."
Get-ChildItem -Path $srcPath -Filter "VMware*" | Remove-Item -Confirm:$false -Force -Recurse

$package = "$PSScriptRoot\artifacts\WindowsServer.ps1.zip"
Compress-Archive -Path $srcPath\** -DestinationPath $package -Force

Write-Host "$package is created successfully."