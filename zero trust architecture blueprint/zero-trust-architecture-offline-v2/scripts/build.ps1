. "$PSScriptRoot/RequiredModules.ps1"

if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
        throw "Insufficient permissions to run this script. Open the PowerShell console as an administrator and run this script again."
}

# We will output everything to the deployment root.
$publicDirectory = "$PSScriptRoot\dependencies"

# Bundle the Windows 2019 STIG DSC zip
$windowsStigDscPackageRoot = "WindowsServer2019Workgroup"
$windowsStigDscConfigFilename = "WindowsServer2019Workgroup.ps1"
$windowsStigDscPackageRootPath = "$PSScriptRoot\source\$windowsStigDscPackageRoot"

# Bundle the online STIG DSC zip
New-Item -Path "$publicDirectory\online" -ItemType "directory" -ErrorAction SilentlyContinue
Compress-Archive -Path "$windowsStigDscPackageRootPath\**" -DestinationPath "$publicDirectory\online\$windowsStigDscConfigFilename.zip" -Force

# Bundle the offline STIG DSC zip
$requiredModules = Get-RequiredModules
$buildDirectory = "$PSScriptRoot\temp.usr"
Remove-Item $buildDirectory -Recurse -Confirm:$false -Force -ErrorAction SilentlyContinue

New-Item -Path $buildDirectory -ItemType "directory"
Copy-Item -Path "$windowsStigDscPackageRootPath" -Destination "$buildDirectory" -Recurse

foreach($requiredModule in $requiredModules) {
    $FullyQualifedName = @{ModuleName="$($requiredModule.ModuleName)";ModuleVersion="$($requiredModule.ModuleVersion)"}
    $ModulePath = (Get-Module -FullyQualifiedName $FullyQualifedName -ListAvailable)[0].ModuleBase | Split-Path
    Write-Verbose "Copying $ModulePath to build folder."
    Copy-Item -Path "$ModulePath" -Destination "$buildDirectory\$windowsStigDscPackageRoot" -Recurse
}

# Zip up the DSC package into the format expected by the DSC VM Extension
New-Item -Path "$publicDirectory\offline" -ItemType "directory" -ErrorAction SilentlyContinue
Compress-Archive -Path "$buildDirectory\$windowsStigDscPackageRoot\**" -DestinationPath "$publicDirectory\offline\$windowsStigDscConfigFilename.zip" -Force
