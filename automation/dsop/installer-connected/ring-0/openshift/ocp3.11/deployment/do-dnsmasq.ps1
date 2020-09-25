param (
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $ScriptsPath,
    [Parameter(Mandatory=$true)] [string] $MasterClusterDns,
    [Parameter(Mandatory=$true)] [string] $MasterPrivateClusterIp,
    [Parameter(Mandatory=$true)] [string] $RoutingSubDomain,
    [Parameter(Mandatory=$true)] [string] $RouterPrivateClusterIp,
    [Parameter(Mandatory=$true)] [string] $MasterHostname,
    [Parameter(Mandatory=$true)] [int] $MasterInstanceCount,
    [Parameter(Mandatory=$true)] [string] $InfraHostname,
    [Parameter(Mandatory=$true)] [int] $InfraInstanceCount,
    [Parameter(Mandatory=$true)] [string] $NodeHostname,
    [Parameter(Mandatory=$true)] [int] $NodeInstanceCount,
    [Parameter(Mandatory=$true)] [bool] $EnableCns,
    [Parameter(Mandatory=$true)] [string] $CnsHostname,
    [Parameter(Mandatory=$true)] [int] $CnsInstanceCount
)

Log-Information "Prepare dnsmasq script"
New-Item -Path $ScriptsPath/dnsmasq-settings.sh -Force -ItemType file -Value @"
cat > /etc/dnsmasq.conf <<FOR
conf-dir=/etc/dnsmasq.d,.rpmnew,.rpmsave,.rpmorig
address=/$MasterClusterDns/$MasterPrivateClusterIp
address=/$RoutingSubDomain/$RouterPrivateClusterIp
FOR

systemctl restart dnsmasq
"@

$jsonFile = New-Base64EncodedJson -ScriptPath $ScriptsPath -ScriptFileName "dnsmasq-settings.sh"

$Job = 1..4 | ForEach-Object -Parallel {
    # Import common files
    $importFiles = Get-ChildItem ".\Common\*.ps1"
    if ($importFiles.Count -gt 0) {
        foreach ($file in $importFiles) {
            Write-Host "Importing common library [$($file.BaseName)]"
            . $file.FullName
        }
    } else {
        Write-Host "This script requires additional modules to be loaded.  Could not find any." -ForegroundColor Red
        Write-Host "Exiting script." -ForegroundColor Red
        exit(1)
    }

    switch ($_) {
        1 {
            Set-LogFile "./deployment-output/dnsmasq-$($using:MasterHostname)_$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"
            Log-Information "alter masters dnsmasq"
            $c = 1
            do {
                $n = ([string]$c).PadLeft(3,"0")
                Log-Information "altering $using:MasterHostname-$($n)v"

                New-AzureLinuxExtension -ResourceGroup $using:ResourceGroup -VmName "$using:MasterHostname-$($n)v" -JsonFile $using:jsonFile

                $c++
            } until ($c -gt $using:MasterInstanceCount)
        }
        2 {
            Set-LogFile "./deployment-output/dnsmasq-$($using:InfraHostname)_$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"
            Log-Information "alter infra dnsmasq"
            $c = 1
            do {
                $n = ([string]$c).PadLeft(3,"0")
                Log-Information "altering $using:InfraHostname-$($n)v"

                New-AzureLinuxExtension -ResourceGroup $using:ResourceGroup -VmName "$using:InfraHostname-$($n)v" -JsonFile $using:jsonFile

                $c++
            } until ($c -gt $using:InfraInstanceCount)
        }
        3 {
            Set-LogFile "./deployment-output/dnsmasq-$($using:NodeHostname)_$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"
            Log-Information "alter node dnsmasq"
            $c = 1
            do {
                $n = ([string]$c).PadLeft(3,"0")
                Log-Information "altering $using:NodeHostname-$($n)v"

                New-AzureLinuxExtension -ResourceGroup $using:ResourceGroup -VmName "$using:NodeHostname-$($n)v" -JsonFile $using:jsonFile

                $c++
            } until ($c -gt $using:NodeInstanceCount)
        }
        4 {
            if ($using:EnableCns)
            {
                Set-LogFile "./deployment-output/dnsmasq-$($using:CnsHostname)_$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"
                Log-Information "alter cns dnsmasq"
                $c = 1
                do {
                    $n = ([string]$c).PadLeft(3,"0")
                    Log-Information "altering $using:CnsHostname-$($n)v"

                    New-AzureLinuxExtension -ResourceGroup $using:ResourceGroup -VmName "$using:CnsHostname-$($n)v" -JsonFile $using:jsonFile

                    $c++
                } until ($c -gt $using:CnsInstanceCount)
            }
        }
    }

    # potential workaround for thread locks
    Start-Sleep -Seconds 5
} -AsJob -ThrottleLimit 5
$Job | Receive-Job -Wait
