Import-Module PowerStig
$osVersion = "2019"


$powerSTIGpath = (Get-Module -Name PowerSTIG).path.Trim("\\PowerStig.psm1")
$DscResults = Test-DsCconfiguration -ComputerName localhost -Detailed
$latestVersion = (Get-Stig -ListAvailable | where TechnologyVersion -eq $OsVersion | where TechnologyRole -eq "MS" | Measure-Object -Maximum -Property Version).Maximum
$outputPath = "C:\$env:COMPUTERNAME.ckl"

$osSTIG = "{0}\StigData\Archive\Windows.Server.{1}\U_MS_Windows_Server_{1}_MS_STIG_V{2}R{3}_Manual-xccdf.xml" -f $powerSTIGpath,$OsVersion,$latestVersion.Major,$latestVersion.Minor
$defender

$XccdfPath  = {$osSTIG}


New-StigCheckList -DscResult $DscResults -XccdfPath $XccdfPath -OutputPath $outputPath 