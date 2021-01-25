<#
.SYNOPSIS
    When "Run as administrator" this script will generate a checklist file via PowerSTIG for Windows Server 2016/2019 that can be viewed with DISA'’'s StigViewer 
    (https://public.cyber.mil/stigs/srg-stig-tools/).
    A checklist is included with this script as an example of the compliance status with manual checklist entries added.
    Please confirm all security settings once deployed to your environment.
.DESCRIPTION
    This script is able to generate checklist files for Server 2019 and 2016, with applications installed on base images (Windows Defender, Internet Explorer, Windows Firewall,
    and DotNet Framework 4)
.NOTES
    This script is included to assist with generating a checklist of a newly deployed VM. Modifications to the script may be required based on organization requirements
.EXAMPLE
    .\GenerateChecklist.ps1
#>

Import-Module PowerStig -verbose -force

#Get OS version
$osVersion = (Get-WmiObject Win32_OperatingSystem).Caption
switch -Wildcard ($osVersion)
{
    "*2016*"
    {
        $osVersion = "2016"
        break
    }
    "*2019*"
    {
        $osVersion = "2019"
        break
    }
}

$powerSTIGpath = (Get-Module -Name PowerSTIG).ModuleBase

# Wait for configuration to apply
while((Get-DscLocalConfigurationManager).LCMState -notmatch "Idle")
{
    start-sleep 5
    Write-Host "Waiting 5 seconds for retry"
}

$dscResults = Test-DscConfiguration -Detailed
$outputPath = "C:\$env:COMPUTERNAME.ckl"

# Format Stig path for Manual CheckFile

# Server STIGs
$latestOsVersion = (Get-Stig -ListAvailable | Where-Object  {$_.TechnologyVersion -eq $OsVersion -and $_.TechnologyRole -eq "MS" }| Measure-Object -Maximum -Property Version).Maximum
$serverOsSTIG = '{0}\StigData\Archive\Windows.Server.{1}\U_MS_Windows_Server_{1}_MS_STIG_V{2}R{3}_Manual-xccdf.xml' -f $powerSTIGpath,$OsVersion,$latestOsVersion.Major,$latestOsVersion.Minor
$manServerSTIG  = "U_MS_Windows_Server_{0}_MS_STIG_V{1}R{2}_Manual-xccdf.xml" -f $OsVersion,$latestOsVersion.Major,$latestOsVersion.Minor

# Windows Defender STIG
$latestDefenderVersion = (Get-Stig -ListAvailable | Where-Object Technology -eq "WindowsDefender"| Measure-Object -Maximum -Property Version).Maximum
$defenderSTIG = '{0}\StigData\Archive\Windows.Defender\U_MS_Windows_Defender_Antivirus_STIG_V{1}R{2}_Manual-xccdf.xml' -f $powerSTIGpath,$latestDefenderVersion.Major,$latestDefenderVersion.Minor

# Internet Explorer STIG
$latestInternetExplorerVersion = (Get-Stig -ListAvailable | Where-Object Technology -eq "InternetExplorer"| Measure-Object -Maximum -Property Version).Maximum
$internetExplorerSTIG = '{0}\StigData\Archive\InternetExplorer\U_MS_IE11_STIG_V{1}R{2}_Manual-xccdf.xml' -f $powerSTIGpath,$latestInternetExplorerVersion.Major,$latestInternetExplorerVersion.Minor

# Windows Firewall STIG
$latestFirewallVersion = (Get-Stig -ListAvailable | Where-Object Technology -eq "WindowsFirewall"| Measure-Object -Maximum -Property Version).Maximum
$firewallSTIG = '{0}\StigData\Archive\Windows.Firewall\U_Windows_Firewall_STIG_V{1}R{2}_Manual-xccdf.xml' -f $powerSTIGpath,$latestFirewallVersion.Major,$latestFirewallVersion.Minor
$manfirewallSTIG  = "U_Windows_Firewall_STIG_V{0}R{1}_Manual-xccdf.xml" -f $latestFirewallVersion.Major,$latestFirewallVersion.Minor


# Array of STIGS to add to checklist
$xccdfPath = @($serverOsSTIG,$defenderSTIG,$internetExplorerSTIG,$firewallSTIG)
$status = "NotAFinding"
$comments = "Not Applicable"
$details = 'Not applicable for this VM as of deployment time {0}' -f $(Get-Date)

$manualRules = @(
    @{
        osVersion = "2019"
        stig = $manServerSTIG
        id   =  @("V-205624","V-205657","V-205661","V-205664","V-205677","V-205699","V-205721","V-205727","V-205746","V-205844","V-205847","V-205848","V-205852","V-205853","V-205854","V-205855")
    },
    @{
        osVersion = "2016"
        stig = $manServerSTIG
        id   =  @("V-224819","V-224820","V-224822","V-224823","V-224824","V-224825","V-224827","V-224836","V-224837","V-224841","V-224842","V-224843","V-224845","V-224848","V-224849","V-224860","V-224861","V-224863","V-225007")
    },
    @{
        osVersion = "2016|2019"
        stig = $manfirewallSTIG
        id   =  @("V-36440")
    }

)

# Generate manual checklist file
$outputPath2 = "c:\ManualCheck.xml"
$xmlWriterSettings = [System.Xml.XmlWriterSettings]::new()
$xmlWriterSettings.Indent = $true
$xmlWriterSettings.IndentChars = "`t"
$xmlWriterSettings.NewLineChars = "`n"
$writer = [System.Xml.XmlWriter]::Create($OutputPath2, $xmlWriterSettings)
$writer.WriteStartElement("stigManualChecklistData")

foreach($item in $manualRules)
{
    if($osVersion -match $item.osVersion)
    {
        foreach($rule in $item.id)
        {

            $writer.WriteStartElement("stigRuleData")
            $writer.WriteStartElement("STIG")
            $writer.WriteString($item.stig)
            $writer.WriteEndElement()
            $writer.WriteStartElement("ID")
            $writer.WriteString($rule)
            $writer.WriteEndElement()
            $writer.WriteStartElement("Status")
            $writer.WriteString($status)
            $writer.WriteEndElement()
            $writer.WriteStartElement("Comments")
            $writer.WriteString($comments)
            $writer.WriteEndElement()
            $writer.WriteStartElement("Details")
            $writer.WriteString($details)
            $writer.WriteEndElement()
            $writer.WriteEndElement()
        }
    }
}

$writer.WriteEndDocument()
$writer.Flush()
$writer.Close()

# Generate Checklist
New-StigCheckList -DscResult $dscResults -XccdfPath $xccdfPath -OutputPath $outputPath -ManualChecklistEntriesFile $outputPath2

# Cleanup checklist manual entries
Remove-Item -Path $outputPath2 -Force -Confirm:$false
