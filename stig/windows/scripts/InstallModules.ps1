. "$PSScriptRoot/RequiredModules.ps1"

# Added to support package provider download on Server 2016
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

$requiredModules = Get-RequiredModules

# Install the required modules
foreach($requiredModule in $requiredModules) {
    Install-Module -Name $requiredModule.ModuleName -RequiredVersion $requiredModule.ModuleVersion -Force
}

# Increase the MaxEnvelope Size
Set-Item -Path WSMan:\localhost\MaxEnvelopeSizekb -Value 8192

# Copy checklist to local directory
mkdir c:\Logs -Force -Confirm:$false

#Get OS version and copy specific checklist file
$osVersion = (Get-WmiObject Win32_OperatingSystem).Caption
switch -Wildcard ($osVersion)
{
    "*2016*"
    {
        
        $baseUri = "https://raw.githubusercontent.com/erjenkin/ato-toolkit/master/stig/windows/scripts/Checklists/Server2016.ckl"
        Invoke-WebRequest -Uri $baseuri -OutFile "c:\Logs\Server2016.ckl"
        break
    }
    "*2019*"
    {
        
        $baseUri = "https://raw.githubusercontent.com/erjenkin/ato-toolkit/master/stig/windows/scripts/Checklists/Server2019.ckl"
        Invoke-WebRequest -Uri $baseuri -OutFile "c:\Logs\Server2019.ckl"
        break
    }
}

#copy checklist generation script
$baseUri = "https://raw.githubusercontent.com/erjenkin/ato-toolkit/master/stig/windows/scripts/Checklists/GenerateChecklist.ps1"
Invoke-WebRequest -Uri $baseuri -OutFile "c:\Logs\GenerateChecklist.ps1"