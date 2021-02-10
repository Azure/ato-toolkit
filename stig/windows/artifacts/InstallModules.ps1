Param(
    [string] 
    [Parameter(Mandatory = $false)]
    $autoInstallDependencies = $false
)

if ($autoInstallDependencies -eq $true) {
    . "$PSScriptRoot\RequiredModules.ps1"

    # Added to support package provider download on Server 2016
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

    $requiredModules = Get-RequiredModules

    # Install the required modules
    foreach ($requiredModule in $requiredModules) {
        Install-Module -Name $requiredModule.ModuleName -RequiredVersion $requiredModule.ModuleVersion -Force
    }
}

# Increase the MaxEnvelope Size
Set-Item -Path WSMan:\localhost\MaxEnvelopeSizekb -Value 8192

# Set Password required for local accounts (STIG V-205700)
Net user DefaultAccount /passwordreq:yes
Net user Guest /passwordreq:yes

# Set Local Admin account password expires True (V-205658)
$localAdmin = Get-LocalUser | Where-Object Description -eq "Built-in account for administering the computer/domain"
Set-LocalUser -name $localAdmin.Name -PasswordNeverExpires $false