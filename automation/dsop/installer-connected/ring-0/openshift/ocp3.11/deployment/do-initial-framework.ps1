param (
    [Parameter(Mandatory=$true)] [DeploymentType] $DeploymentType,
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $ProductLine,
    [Parameter(Mandatory=$true)] [string] $Environment,
    [Parameter(Mandatory=$true)] [string] $RegionLocation,
    [Parameter(Mandatory=$true)] [string] $AzureLocation,
    [Parameter(Mandatory=$true)] [string] $DiagnosticsStorage,
    [Parameter(Mandatory=$true)] [string] $OpenShiftRegistry,
    [Parameter(Mandatory=$true)] [string] $BastionShortname,
    [Parameter(Mandatory=$true)] [string] $MasterShortname,
    [Parameter(Mandatory=$true)] [string] $NodeShortname,
    [Parameter(Mandatory=$true)] [string] $InfraShortname,
    [Parameter(Mandatory=$true)] [string] $CnsShortname,
    [Parameter(Mandatory=$true)] [string] $BastionHostname,
    [Parameter(Mandatory=$true)] [string] $MasterHostname,
    [Parameter(Mandatory=$true)] [string] $NodeHostname,
    [Parameter(Mandatory=$true)] [string] $InfraHostname,
    [Parameter(Mandatory=$true)] [string] $CnsHostname,
    [Parameter(Mandatory=$true)] [string] $ClusterType,
    [Parameter(Mandatory=$true)] [string] $MasterPrivateClusterIp,
    [Parameter(Mandatory=$true)] [string] $RouterPrivateClusterIp,
    [Parameter(Mandatory=$true)] [string] $MasterInfraSubnetName,
    [Parameter(Mandatory=$true)] [int] $FaultDomainCount,
    [Parameter(Mandatory=$true)] [int] $UpdateDomainCount,
    [Parameter(Mandatory=$true)] [bool] $EnableCns
)

Log-Parameters -ScriptName $MyInvocation.MyCommand -ScriptArgs $MyInvocation.MyCommand.Parameters

$masterAvailabilitySet = "$Environment-$RegionLocation-$MasterShortname-AS01"
$infraAvailabilitySet = "$Environment-$RegionLocation-$InfraShortname-AS01"
$nodeAvailabilitySet = "$Environment-$RegionLocation-$NodeShortname-AS01"
$cnsAvailabilitySet = "$Environment-$RegionLocation-$CnsShortname-AS01"
$masterLoadBalancerName = "$Environment-$RegionLocation-$MasterShortname-LB"
$infraLoadBalancerName = "$Environment-$RegionLocation-$InfraShortname-LB"
$loadBalancerBackEndPoolName = "loadBalancerBackEnd"
$sshRuleName = "allowSSHin_all"
$httpsRuleName = "allowHTTPS_all"
$httpRuleName = "allowHTTPIn_all"
$bastionNsg = "$BastionHostname-NSG"
$cnsNsg = "$CnsHostname-NSG"
$infraNsg = "$InfraHostname-NSG"
$masterNsg = "$MasterHostname-NSG"
$nodeNsg = "$NodeHostname-NSG"
$httpsProbe = "httpsProbe"
$httpProbe = "httpProbe"

$Job = 1..13 | ForEach-Object -Parallel {
    switch ($_) {
        1 {
            $argList = "vm availability-set create -n $using:masterAvailabilitySet " +
                "-g $using:ResourceGroup " +
                "--platform-fault-domain-count $using:FaultDomainCount " +
                "-o table "

            if ($using:UpdateDomainCount -gt 0)
            {
                $argList += "--platform-update-domain-count $using:UpdateDomainCount "
            }
            ./do-run-command.ps1 -Arguments $argList -LogFile "./deployment-output/vm-availability-set-master_$_$(Get-Date -format MM-dd-yyyy-hhmmss).log"
        }
        2 {
            $argList = "vm availability-set create -n $using:infraAvailabilitySet " +
                "-g $using:ResourceGroup " +
                "--platform-fault-domain-count $using:FaultDomainCount " +
                "-o table "

            if ($using:UpdateDomainCount -gt 0)
            {
                $argList += "--platform-update-domain-count $using:UpdateDomainCount "
            }
            ./do-run-command.ps1 -Arguments $argList -LogFile "./deployment-output/vm-availability-set-infra_$_$(Get-Date -format MM-dd-yyyy-hhmmss).log"
        }
        3 {
            $argList = "vm availability-set create -n $using:nodeAvailabilitySet " +
                "-g $using:ResourceGroup " +
                "--platform-fault-domain-count $using:FaultDomainCount " +
                "-o table "

            if ($using:UpdateDomainCount -gt 0)
            {
                $argList += "--platform-update-domain-count $using:UpdateDomainCount "
            }
            ./do-run-command.ps1 -Arguments $argList -LogFile "./deployment-output/vm-availability-set-infra_$_$(Get-Date -format MM-dd-yyyy-hhmmss).log"
        }
        4 {
            if ($using:EnableCns)
            {
                $argList = "vm availability-set create -n $using:cnsAvailabilitySet " +
                    "-g $using:ResourceGroup " +
                    "--platform-fault-domain-count $using:FaultDomainCount " +
                    "-o table "

                if ($using:UpdateDomainCount -gt 0)
                {
                    $argList += "--platform-update-domain-count $using:UpdateDomainCount "
                }
                ./do-run-command.ps1 -Arguments $argList -LogFile "./deployment-output/vm-availability-set-infra_$_$(Get-Date -format MM-dd-yyyy-hhmmss).log"
            }
        }
        5 {
            $argList = "network lb create -n $using:masterLoadBalancerName " +
                        "-g $using:ResourceGroup " +
                        "--backend-pool-name $using:loadBalancerBackEndPoolName " +
                        "-o table "

            if ($using:ClusterType -eq "public")
            {
                $PublicIpName = "$using:masterLoadBalancerName-PIP"
                $publicIpArgList = "network public-ip create -g $using:ResourceGroup -n $PublicIpName"
                ./do-run-command.ps1 -Arguments $publicIpArgList -LogFile "./deployment-output/network-lb-pip-create-master_$_$(Get-Date -format MM-dd-yyyy-hhmmss).log"

                $argList += "--public-ip-address `"$PublicIpName`" "
            }
            else
            {
                $argList += "--subnet `"$using:MasterInfraSubnetName`" " +
                            "--private-ip-address $using:MasterPrivateClusterIp " +
                            "--public-ip-address `"`" "
            }

            ./do-run-command.ps1 -Arguments $argList -LogFile "./deployment-output/network-lb-create-master_$_$(Get-Date -format MM-dd-yyyy-hhmmss).log"
        }
        6 {
            $argList = "network lb create -n $using:infraLoadBalancerName " +
                        "-g $using:ResourceGroup " +
                        "--backend-pool-name $using:loadBalancerBackEndPoolName " +
                        "-o table "

            if ($using:ClusterType -eq "public")
            {
                $PublicIpName = "$using:infraLoadBalancerName-PIP"
                $publicIpArgList = "network public-ip create -g $using:ResourceGroup -n $PublicIpName"
                ./do-run-command.ps1 -Arguments $publicIpArgList -LogFile "./deployment-output/network-lb-pip-create-infra_$_$(Get-Date -format MM-dd-yyyy-hhmmss).log"

                $argList += "--public-ip-address `"$PublicIpName`" "
            }
            else
            {
                $argList += "--subnet `"$using:MasterInfraSubnetName`" " +
                            "--private-ip-address $using:RouterPrivateClusterIp " +
                            "--public-ip-address `"`" "
            }

            ./do-run-command.ps1 -Arguments $argList -LogFile "./deployment-output/network-lb-create-infra_$_$(Get-Date -format MM-dd-yyyy-hhmmss).log"
        }
        7 {
            $argList = "storage account create -l `"$using:AzureLocation`" " +
                "--resource-group $using:ResourceGroup " +
                "-n $using:DiagnosticsStorage " +
                "--sku Standard_LRS " +
                "-o table"
            ./do-run-command.ps1 -Arguments $argList -LogFile "./deployment-output/storage-account-diag-create_$_$(Get-Date -format MM-dd-yyyy-hhmmss).log"
        }
        8 {
            $argList = "storage account create -l `"$using:AzureLocation`" " +
                "--resource-group $using:ResourceGroup " +
                "-n $using:OpenShiftRegistry " +
                "--sku Standard_LRS " +
                "-o table"
            ./do-run-command.ps1 -Arguments $argList -LogFile "./deployment-output/storage-account-ocpreg-create_$_$(Get-Date -format MM-dd-yyyy-hhmmss).log"
        }
        9 {
            $argList = "network nsg create -n $using:bastionNsg " +
                "-g $using:ResourceGroup " +
                "-o table"
            ./do-run-command.ps1 -Arguments $argList -LogFile "./deployment-output/network-nsg-create-bastion_$_$(Get-Date -format MM-dd-yyyy-hhmmss).log"
        }
        10 {
            if ($using:EnableCns)
            {
                $argList = "network nsg create -n $using:cnsNsg " +
                    "-g $using:ResourceGroup " +
                    "-o table"
                ./do-run-command.ps1 -Arguments $argList -LogFile "./deployment-output/network-nsg-create-cns_$_$(Get-Date -format MM-dd-yyyy-hhmmss).log"
            }
        }
        11 {
            $argList = "network nsg create -n $using:infraNsg " +
                "-g $using:ResourceGroup " +
                "-o table"
            ./do-run-command.ps1 -Arguments $argList -LogFile "./deployment-output/network-nsg-create-infra_$_$(Get-Date -format MM-dd-yyyy-hhmmss).log"
        }
        12 {
            $argList = "network nsg create -n $using:masterNsg " +
                "-g $using:ResourceGroup " +
                "-o table"
            ./do-run-command.ps1 -Arguments $argList -LogFile "./deployment-output/network-nsg-create-master_$_$(Get-Date -format MM-dd-yyyy-hhmmss).log"
        }
        13 {
            $argList = "network nsg create -n $using:nodeNsg " +
                "-g $using:ResourceGroup " +
                "-o table"
            ./do-run-command.ps1 -Arguments $argList -LogFile "./deployment-output/network-nsg-create-node_$_$(Get-Date -format MM-dd-yyyy-hhmmss).log"
        }
    }
    # potential workaround for thread locks
    Start-Sleep -Seconds 5
} -AsJob -ThrottleLimit 13
$Job | Receive-Job -Wait

$Job = 1..2 | ForEach-Object -Parallel {
    switch ($_) {
        1 {
            $argList = "network lb probe create -g $using:ResourceGroup " +
                "-n `"$using:httpsProbe`" " +
                "--lb-name `"$using:masterLoadBalancerName`" " +
                "--port 443 " +
                "--protocol tcp " +
                "-o table"
            ./do-run-command.ps1 -Arguments $argList -LogFile "./deployment-output/network-lb-probe-create-master_$_$(Get-Date -format MM-dd-yyyy-hhmmss).log"
        }
        2 {
            $argList = "network lb probe create -g $using:ResourceGroup " +
                "-n `"$using:httpsProbe`" " +
                "--lb-name `"$using:infraLoadBalancerName`" " +
                "--port 443 " +
                "--protocol tcp " +
                "-o table"
            ./do-run-command.ps1 -Arguments $argList -LogFile "./deployment-output/network-lb-probe-create-infra-https_$_$(Get-Date -format MM-dd-yyyy-hhmmss).log"
        }
    }
    # potential workaround for thread locks
    Start-Sleep -Seconds 5
} -AsJob -ThrottleLimit 10
$Job | Receive-Job -Wait

$Job = 1..1 | ForEach-Object -Parallel {
    switch ($_) {
        1 {
            $argList = "network lb probe create -g $using:ResourceGroup " +
                "-n `"$using:httpProbe`" " +
                "--lb-name `"$using:infraLoadBalancerName`" " +
                "--port 80 " +
                "--protocol tcp " +
                "-o table"
            ./do-run-command.ps1 -Arguments $argList -LogFile "./deployment-output/network-lb-probe-create-infra-http_$_$(Get-Date -format MM-dd-yyyy-hhmmss).log"
        }
    }
} -AsJob -ThrottleLimit 10
$Job | Receive-Job -Wait

$Job = 1..3 | ForEach-Object -Parallel {
    switch ($_) {
        1 {
            $argList = "network lb rule create -g $using:ResourceGroup " +
                "--name `"OpenShiftAdminConsole`" " +
                "--lb-name `"$using:masterLoadBalancerName`" " +
                "--probe-name `"$using:httpsProbe`" " +
                "--protocol tcp " +
                "--frontend-port 443 " +
                "--backend-port 443 " +
                "--backend-pool-name `"$using:loadBalancerBackEndPoolName`" " +
                "--load-distribution SourceIP " +
                "--idle-timeout 30 " +
                "-o table"
            ./do-run-command.ps1 -Arguments $argList -LogFile "./deployment-output/network-lb-rule-create-master_$_$(Get-Date -format MM-dd-yyyy-hhmmss).log"
        }
        2 {
            $argList = "network lb rule create -g $using:ResourceGroup " +
                "--name `"OpenShiftRouterHTTPS`" " +
                "--lb-name $using:infraLoadBalancerName " +
                "--probe-name $using:httpsProbe " +
                "--protocol tcp " +
                "--frontend-port 443 " +
                "--backend-port 443 " +
                " --backend-pool-name $using:loadBalancerBackEndPoolName " +
                "-o table"
            ./do-run-command.ps1 -Arguments $argList -LogFile "./deployment-output/network-lb-rule-create-infra-https_$_$(Get-Date -format MM-dd-yyyy-hhmmss).log"
        }
    }
    # potential workaround for thread locks
    Start-Sleep -Seconds 5
} -AsJob -ThrottleLimit 10
$Job | Receive-Job -Wait

$Job = 1..1 | ForEach-Object -Parallel {
    switch ($_) {
        1 {
            $argList = "network lb rule create -g $using:ResourceGroup " +
                "--name `"OpenShiftRouterHTTP`" " +
                "--lb-name $using:infraLoadBalancerName " +
                "--probe-name $using:httpProbe " +
                "--protocol tcp " +
                "--frontend-port 80 " +
                "--backend-port 80 " +
                " --backend-pool-name $using:loadBalancerBackEndPoolName " +
                "-o table"
            ./do-run-command.ps1 -Arguments $argList -LogFile "./deployment-output/network-lb-rule-create-infra-http_$_$(Get-Date -format MM-dd-yyyy-hhmmss).log"
        }
    }
} -AsJob -ThrottleLimit 10
$Job | Receive-Job -Wait

$Job = 1..6 | ForEach-Object -Parallel {
    switch ($_) {
        1 {
            $argList = "network nsg rule create -g $using:ResourceGroup " +
                "--nsg-name $using:bastionNsg " +
                "-n $using:sshRuleName " +
                "--priority 100 " +
                "--access Allow " +
                "--direction Inbound " +
                "--protocol Tcp " +
                "--destination-address-prefixes `* " +
                "--source-address-prefixes `* " +
                "--source-port-ranges `* " +
                "--destination-port-ranges 22 " +
                "-o table"
            ./do-run-command.ps1 -Arguments $argList -LogFile "./deployment-output/network-nsg-rule-ssh-bastion_$_$(Get-Date -format MM-dd-yyyy-hhmmss).log"
        }
        2 {
            $argList = "network nsg rule create -g $using:ResourceGroup " +
                "--nsg-name $using:infraNsg " +
                "-n $using:httpsRuleName " +
                "--priority 200 " +
                "--access Allow " +
                "--direction Inbound " +
                "--protocol Tcp " +
                "--destination-address-prefixes `* " +
                "--source-address-prefixes `* " +
                "--source-port-ranges `* " +
                "--destination-port-ranges 443 " +
                "-o table"
            ./do-run-command.ps1 -Arguments $argList -LogFile "./deployment-output/network-nsg-rule-https-infra_$_$(Get-Date -format MM-dd-yyyy-hhmmss).log"
        }
        3 {
            $argList = "network nsg rule create -g $using:ResourceGroup " +
                "--nsg-name $using:infraNsg " +
                "-n $using:httpRuleName " +
                "--priority 300 " +
                "--access Allow " +
                "--direction Inbound " +
                "--protocol Tcp " +
                "--destination-address-prefixes `* " +
                "--source-address-prefixes `* " +
                "--source-port-ranges `* " +
                "--destination-port-ranges 80 " +
                "-o table"
            ./do-run-command.ps1 -Arguments $argList -LogFile "./deployment-output/network-nsg-rule-http-infra_$_$(Get-Date -format MM-dd-yyyy-hhmmss).log"
        }
        4 {
            $argList = "network nsg rule create -g $using:ResourceGroup " +
                "--nsg-name $using:masterNsg " +
                "-n $using:httpsRuleName " +
                "--priority 200 " +
                "--access Allow " +
                "--direction Inbound " +
                "--protocol Tcp " +
                "--destination-address-prefixes `* " +
                "--source-address-prefixes `* " +
                "--source-port-ranges `* " +
                "--destination-port-ranges 443 " +
                "-o table"
            ./do-run-command.ps1 -Arguments $argList -LogFile "./deployment-output/network-nsg-https-infra_$_$(Get-Date -format MM-dd-yyyy-hhmmss).log"
        }
        5 {
            $argList = "network nsg rule create -g $using:ResourceGroup " +
                "--nsg-name $using:nodeNsg " +
                "-n $using:httpsRuleName " +
                "--priority 200 " +
                "--access Allow " +
                "--direction Inbound " +
                "--protocol Tcp " +
                "--destination-address-prefixes `* " +
                "--source-address-prefixes `* " +
                "--source-port-ranges `* " +
                "--destination-port-ranges 443 " +
                "-o table"
            ./do-run-command.ps1 -Arguments $argList -LogFile "./deployment-output/network-nsg-rule-https-infra_$_$(Get-Date -format MM-dd-yyyy-hhmmss).log"
        }
        6 {
            $argList = "network nsg rule create -g $using:ResourceGroup " +
                "--nsg-name $using:nodeNsg " +
                "-n $using:httpRuleName " +
                "--priority 300 " +
                "--access Allow " +
                "--direction Inbound " +
                "--protocol Tcp " +
                "--destination-address-prefixes `* " +
                "--source-address-prefixes `* " +
                "--source-port-ranges `* " +
                "--destination-port-ranges 80 " +
                "-o table"
            ./do-run-command.ps1 -Arguments $argList -LogFile "./deployment-output/network-nsg-rule-http-infra_$_$(Get-Date -format MM-dd-yyyy-hhmmss).log"
        }
    }
    # potential workaround for thread locks
    Start-Sleep -Seconds 5
} -AsJob -ThrottleLimit 10
$Job | Receive-Job -Wait

Log-Footer -ScriptName $MyInvocation.MyCommand
