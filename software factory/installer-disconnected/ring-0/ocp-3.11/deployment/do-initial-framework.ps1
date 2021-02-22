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
    [Parameter(Mandatory=$true)] [bool] $EnableCns,
    [Parameter(Mandatory=$true)] [string] $AvailabilitySetPrefix
)

$masterAvailabilitySet = "$AvailabilitySetPrefix-$MasterShortname-AS01"
$infraAvailabilitySet = "$AvailabilitySetPrefix-$InfraShortname-AS01"
$nodeAvailabilitySet = "$AvailabilitySetPrefix-$NodeShortname-AS01"
$cnsAvailabilitySet = "$AvailabilitySetPrefix-$CnsShortname-AS01"
$masterLoadBalancerName = "$AvailabilitySetPrefix-$MasterShortname-LB"
$infraLoadBalancerName = "$AvailabilitySetPrefix-$InfraShortname-LB"
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

$logDir = "$($(Get-Location).Path)/deployment-output"
$logRunTime = $(Get-Date -format MM-dd-yyyy-hhmmss)

$Job = 1..13 | ForEach-Object -Parallel {
    switch ($_) {
        1 {
            Set-LogFile -LogFile "$using:logDir/vm-availability-set-master_$_$using:logRunTime.log"
            $argList = "vm availability-set create -n $using:masterAvailabilitySet " +
                "-g $using:ResourceGroup " +
                "--platform-fault-domain-count $using:FaultDomainCount " +
                "-o table "

            if ($using:UpdateDomainCount -gt 0)
            {
                $argList += "--platform-update-domain-count $using:UpdateDomainCount "
            }
            Run-Command -Process "az" -Arguments $argList
        }
        2 {
            Set-LogFile -LogFile "$using:logDir/vm-availability-set-infra_$_$using:logRunTime.log"
            $argList = "vm availability-set create -n $using:infraAvailabilitySet " +
                "-g $using:ResourceGroup " +
                "--platform-fault-domain-count $using:FaultDomainCount " +
                "-o table "

            if ($using:UpdateDomainCount -gt 0)
            {
                $argList += "--platform-update-domain-count $using:UpdateDomainCount "
            }
            Run-Command -Process "az" -Arguments $argList
        }
        3 {
            Set-LogFile -LogFile "$using:logDir/vm-availability-set-infra_$_$using:logRunTime.log"
            $argList = "vm availability-set create -n $using:nodeAvailabilitySet " +
                "-g $using:ResourceGroup " +
                "--platform-fault-domain-count $using:FaultDomainCount " +
                "-o table "

            if ($using:UpdateDomainCount -gt 0)
            {
                $argList += "--platform-update-domain-count $using:UpdateDomainCount "
            }
            Run-Command -Process "az" -Arguments $argList
        }
        4 {
            if ($using:EnableCns)
            {
                Set-LogFile -LogFile "$using:logDir/vm-availability-set-infra_$_$using:logRunTime.log"
                $argList = "vm availability-set create -n $using:cnsAvailabilitySet " +
                    "-g $using:ResourceGroup " +
                    "--platform-fault-domain-count $using:FaultDomainCount " +
                    "-o table "
    
                if ($using:UpdateDomainCount -gt 0)
                {
                    $argList += "--platform-update-domain-count $using:UpdateDomainCount "
                }
                Run-Command -Process "az" -Arguments $argList
            }
        }
        5 {
            Set-LogFile -LogFile "$using:logDir/network-create-master_$_$using:logRunTime.log"
            $argList = "network lb create -n $using:masterLoadBalancerName " +
                        "-g $using:ResourceGroup " +
                        "--backend-pool-name $using:loadBalancerBackEndPoolName " +
                        "-o table "

            if ($using:ClusterType -eq "public")
            {
                $PublicIpName = "$using:masterLoadBalancerName-PIP"
                $publicIpArgList = "network public-ip create -g $using:ResourceGroup -n $PublicIpName"
                Run-Command -Process "az" -Arguments $publicIpArgList

                $argList += "--public-ip-address `"$PublicIpName`" "
            }
            else
            {
                $argList += "--subnet `"$using:MasterInfraSubnetName`" " +
                            "--private-ip-address $using:MasterPrivateClusterIp " +
                            "--public-ip-address `"`" "
            }
            Run-Command -Process "az" -Arguments $argList
        }
        6 {
            Set-LogFile -LogFile "$using:logDir/network-create-infra_$_$using:logRunTime.log"
            $argList = "network lb create -n $using:infraLoadBalancerName " +
                        "-g $using:ResourceGroup " +
                        "--backend-pool-name $using:loadBalancerBackEndPoolName " +
                        "-o table "

            if ($using:ClusterType -eq "public")
            {
                $PublicIpName = "$using:infraLoadBalancerName-PIP"
                $publicIpArgList = "network public-ip create -g $using:ResourceGroup -n $PublicIpName"
                Run-Command -Process "az" -Arguments $publicIpArgList

                $argList += "--public-ip-address `"$PublicIpName`" "
            }
            else
            {
                $argList += "--subnet `"$using:MasterInfraSubnetName`" " +
                            "--private-ip-address $using:RouterPrivateClusterIp " +
                            "--public-ip-address `"`" "
            }
            Run-Command -Process "az" -Arguments $argList
        }
        7 {
            Set-LogFile -LogFile "$using:logDir/storage-account-diag-create_$_$using:logRunTime.log"
            $argList = "storage account create -l `"$using:AzureLocation`" " +
                "--resource-group $using:ResourceGroup " +
                "-n $using:DiagnosticsStorage " +
                "--sku Standard_LRS " +
                "-o table"
            Run-Command -Process "az" -Arguments $argList
        }
        8 {
            Set-LogFile -LogFile "$using:logDir/storage-account-ocpreg-create_$_$using:logRunTime.log"
            $argList = "storage account create -l `"$using:AzureLocation`" " +
                "--resource-group $using:ResourceGroup " +
                "-n $using:OpenShiftRegistry " +
                "--sku Standard_LRS " +
                "-o table"
            Run-Command -Process "az" -Arguments $argList
        }
        9 {
            Set-LogFile -LogFile "$using:logDir/network-nsg-create-bastion_$_$using:logRunTime.log"
            $argList = "network nsg create -n $using:bastionNsg " +
                "-g $using:ResourceGroup " +
                "-o table"
            Run-Command -Process "az" -Arguments $argList
        }
        10 {
            if ($using:EnableCns)
            {
                Set-LogFile -LogFile "$using:logDir/network-nsg-create-cns_$_$using:logRunTime.log"
                $argList = "network nsg create -n $using:cnsNsg " +
                    "-g $using:ResourceGroup " +
                    "-o table"
                Run-Command -Process "az" -Arguments $argList
            }
        }
        11 {
            Set-LogFile -LogFile "$using:logDir/network-nsg-create-infra_$_$using:logRunTime.log"
            $argList = "network nsg create -n $using:infraNsg " +
                "-g $using:ResourceGroup " +
                "-o table"
            Run-Command -Process "az" -Arguments $argList
        }
        12 {
            Set-LogFile -LogFile "$using:logDir/network-nsg-create-master_$_$using:logRunTime.log"
            $argList = "network nsg create -n $using:masterNsg " +
                "-g $using:ResourceGroup " +
                "-o table"
            Run-Command -Process "az" -Arguments $argList
        }
        13 {
            Set-LogFile -LogFile "$using:logDir/network-nsg-create-node_$_$using:logRunTime.log"
            $argList = "network nsg create -n $using:nodeNsg " +
                "-g $using:ResourceGroup " +
                "-o table"
            Run-Command -Process "az" -Arguments $argList
        }
    }
    # potential workaround for thread locks
    Start-Sleep -Seconds 5
} -AsJob -ThrottleLimit 13
$Job | Receive-Job -Wait

$Job = 1..2 | ForEach-Object -Parallel {
    switch ($_) {
        1 {
            Set-LogFile -LogFile "$using:logDir/network-lb-probe-create-master_$_$using:logRunTime.log"
            $argList = "network lb probe create -g $using:ResourceGroup " +
                "-n `"$using:httpsProbe`" " +
                "--lb-name `"$using:masterLoadBalancerName`" " +
                "--port 443 " +
                "--protocol tcp " +
                "-o table"
            Run-Command -Process "az" -Arguments $argList
        }
        2 {
            Set-LogFile -LogFile "$using:logDir/network-lb-probe-create-infra-https_$_$using:logRunTime.log"
            $argList = "network lb probe create -g $using:ResourceGroup " +
                "-n `"$using:httpsProbe`" " +
                "--lb-name `"$using:infraLoadBalancerName`" " +
                "--port 443 " +
                "--protocol tcp " +
                "-o table"
            Run-Command -Process "az" -Arguments $argList
        }
    }
    # potential workaround for thread locks
    Start-Sleep -Seconds 5
} -AsJob -ThrottleLimit 10
$Job | Receive-Job -Wait

$Job = 1..1 | ForEach-Object -Parallel {
    switch ($_) {
        1 {
            Set-LogFile -LogFile "$using:logDir/network-lb-probe-create-infra-http_$_$using:logRunTime.log"
            $argList = "network lb probe create -g $using:ResourceGroup " +
                "-n `"$using:httpProbe`" " +
                "--lb-name `"$using:infraLoadBalancerName`" " +
                "--port 80 " +
                "--protocol tcp " +
                "-o table"
            Run-Command -Process "az" -Arguments $argList
        }
    }
} -AsJob -ThrottleLimit 10
$Job | Receive-Job -Wait

$Job = 1..3 | ForEach-Object -Parallel {
    switch ($_) {
        1 {
            Set-LogFile -LogFile "$using:logDir/network-lb-rule-create-master_$_$using:logRunTime.log"
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
            Run-Command -Process "az" -Arguments $argList
        }
        2 {
            Set-LogFile -LogFile "$using:logDir/network-lb-rule-create-infra-https_$_$using:logRunTime.log"
            $argList = "network lb rule create -g $using:ResourceGroup " +
                "--name `"OpenShiftRouterHTTPS`" " +
                "--lb-name $using:infraLoadBalancerName " +
                "--probe-name $using:httpsProbe " +
                "--protocol tcp " +
                "--frontend-port 443 " +
                "--backend-port 443 " +
                " --backend-pool-name $using:loadBalancerBackEndPoolName " +
                "-o table"
            Run-Command -Process "az" -Arguments $argList
        }
    }
    # potential workaround for thread locks
    Start-Sleep -Seconds 5
} -AsJob -ThrottleLimit 10
$Job | Receive-Job -Wait

$Job = 1..1 | ForEach-Object -Parallel {
    switch ($_) {
        1 {
            Set-LogFile -LogFile "$using:logDir/network-lb-rule-create-infra-http_$_$using:logRunTime.log"
            $argList = "network lb rule create -g $using:ResourceGroup " +
                "--name `"OpenShiftRouterHTTP`" " +
                "--lb-name $using:infraLoadBalancerName " +
                "--probe-name $using:httpProbe " +
                "--protocol tcp " +
                "--frontend-port 80 " +
                "--backend-port 80 " +
                " --backend-pool-name $using:loadBalancerBackEndPoolName " +
                "-o table"
            Run-Command -Process "az" -Arguments $argList
        }
    }
} -AsJob -ThrottleLimit 10
$Job | Receive-Job -Wait

$Job = 1..6 | ForEach-Object -Parallel {
    switch ($_) {
        1 {
            Set-LogFile -LogFile "$using:logDir/network-nsg-rule-ssh-bastion_$_$using:logRunTime.log"
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
            Run-Command -Process "az" -Arguments $argList
        }
        2 {
            Set-LogFile -LogFile "$using:logDir/network-nsg-rule-https-infra_$_$using:logRunTime.log"
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
            Run-Command -Process "az" -Arguments $argList
        }
        3 {
            Set-LogFile -LogFile "$using:logDir/network-nsg-rule-http-infra_$_$using:logRunTime.log"
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
            Run-Command -Process "az" -Arguments $argList
        }
        4 {
            Set-LogFile -LogFile "$using:logDir/network-nsg-https-infra_$_$using:logRunTime.log"
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
            Run-Command -Process "az" -Arguments $argList
        }
        5 {
            Set-LogFile -LogFile "$using:logDir/network-nsg-rule-https-infra_$_$using:logRunTime.log"
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
            Run-Command -Process "az" -Arguments $argList
        }
        6 {
            Set-LogFile -LogFile "$using:logDir/network-nsg-rule-http-infra_$_$using:logRunTime.log"
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
            Run-Command -Process "az" -Arguments $argList
        }
    }
    # potential workaround for thread locks
    Start-Sleep -Seconds 5
} -AsJob -ThrottleLimit 10
$Job | Receive-Job -Wait

Log-Footer -ScriptName $MyInvocation.MyCommand







# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUbDN122v/+BK7Po0N5ocslrv2
# P/igggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
# AQsFADAYMRYwFAYDVQQDDA1KZXJlbXlPbGFjaGVhMB4XDTIwMDgzMTIxMTUxMFoX
# DTIxMDgzMTIxMjQ1OVowGDEWMBQGA1UEAwwNSmVyZW15T2xhY2hlYTCCAiIwDQYJ
# KoZIhvcNAQEBBQADggIPADCCAgoCggIBAJu5Y9YhmKGhwU+/kj7dsj1OvrliwUCe
# kdPsfdTAPh9peuKKF+ye8U3l3UT8luf5nCYlG/eKe5YxI3pBYhfZwy7yKZpsx5Tn
# ST7t38owgktj0W6YYfoDgfR4zwLtRk3taNWiZeyHu/UhszNs4d3L9wl6Ei/otfRt
# jyz1UO40361YWriD43jbnsCLjVpIfiwW2LH1H9cVoCLnbMZ217rpVxDiTlFPBGeW
# Bk2pxPn5Z2Ly1j6q/SlliEOKDXXrPQZz+sSc3L/ZXBl7D2/ua4+xJmDw/XE1GUBA
# Pldde/IHAzmp6lHHgdQLjCaks//cucDeYBzVTD8XZo8T9WIWU6o6I6SRzGKSIHcX
# SoKVy1hjaW14wJHImw/nlnCgDLMcBBpnRFo6UHAAUzpWlcgqCC+johdXVSa62+hP
# bLwgqfm6uty0rJRwkhbm1Qi0w6HOUZiIkBIz/5Q83t9nLhWL+uWndKIe9BiVfl1f
# x0p5Ax5hzWD5PV1rjrXSQLpL9PRLKcEAy7EoXa/5VGGKSAOrUZdey39vL3AOct0w
# i3vh49DTfWXuxxHbiWz2VEIZqNWQu/rIi9uiCvzaFUo19DwSZrv1ac+OOmZsloqB
# yDugGWFmxiQjEFWtGxEqwDXPDsJE/gKEPvUha37YCI6iQTtcwiwJpnPfGWODqUHH
# 0/NuToVp4ci5AgMBAAGjRjBEMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggr
# BgEFBQcDAzAdBgNVHQ4EFgQU16Rx2qHCuXNeExsbMFbSE/Io0NYwDQYJKoZIhvcN
# AQELBQADggIBAG+8jfz9QCzSUK5WGIW0gnEK3rN8oxmSax7C6HJfGPMLXHBEWtBt
# ZCeD8XXkTMu8fhvQDseGgxJ4NmRR+s1d8YtnVgtDbEhO/FHSpOPonTvIx13t37Uz
# Tbvq0ZLeB6z55noAOIhXBs9or1pzxio71sDNfYpIB6s41X5/m1UZk8toxcPDqQGL
# Kg3C3xqgg9+2kQ16flYKvZh2UoK5Y0EyEb8rMc+6AFH3GgcP7yoUsUENP9vkLbXm
# 2VRMIzd/Tee7oKQK50K1GxtlWLUUjuAUMCQh+9K/JyAUro9jfMNHCGcPTaayXBvl
# kaCOjb1IrKgtsS/c2p7mgbssdFHHGPBlbggogGFxYof+6SDI2YB8AqT3RYJdJH4c
# 6StsYUka1faCYcZfz+DIm2+avSCKdliOb285WT8yqoh7P2qN6bLt2au0IsfUKR+d
# EgSL3waCmT+xUI6BI6mpnSjgA0/Hr6I/wkxHu/hk0G0q4OdBpXpSzCzurKPdQWB+
# K/PaQSCyEGk4IGqFrHMx863mtW+mlm6jCM/5/b5ugAmF4XoNkVzdmfFhepqq4h0v
# ioKE+1sLxgq2lFtKAZMjpJB7HZ9KVQcb/hSYlgms/mG6P+4GIhf7ZfvlI2LsCdbV
# 42kEAfDVDuHcCqWyJr43vm+vY6xzjDRnNmaqVJgH1sZO0kwajDOKkm/JMYICzTCC
# AskCAQEwLDAYMRYwFAYDVQQDDA1KZXJlbXlPbGFjaGVhAhAVrGjoMQw2rkF3eYcz
# j/kHMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqG
# SIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3
# AgEVMCMGCSqGSIb3DQEJBDEWBBTWuDR681Yj2iU2wMk5glPrpxuCczANBgkqhkiG
# 9w0BAQEFAASCAgAxU2vhhdYIES9Gf0FvCe2xBCXH17RfZXHBB+gSTX4rhuJy2GCO
# sPQPjN3fTkCtvV54gtGNbUxiBchwR21FtdzYhcSvcPAD8Zc1zHMJEsZ5n1o3Uypk
# a69GkLkuLxJZ1vloG0TAmJVYfanC19BL5GYtduxtMLkY3+TEPg5wMLwemgn/JhD6
# AiTTpsordiGSGV0weIHkQmL3dyG8GAEl8R1d+vB2+ggZRmow6SnSpghXjNe07pBT
# ZnSKIDC2uCZLovwSGHLTrRNNhQTtPkNSlbsw6I///EYn/lIz3UHYqqpBEG0podTT
# xcJLY2FsX70mMCQNU5LwofPUKQ2sPre2iQU5TUUmX/mvZUgTyE+cJe33I5z+8EkZ
# ayFbD+a/Nwoe/Tydk3pLzXJKZLg00+Yfa4QW7xCseYmy/gzckMG3TK8ut6AxWEaz
# VtBAmvecVcJe0HaTMDlOO3L0lBIkE2/7fyZerMpyzT3TFqC0OQh+75PkxvM7BjNN
# ZFelV2THLbgWW2Uk4ssZ0n8/B9Cdqw6XvVIF/ipJ09NQGKbY+I/xjXJRMcIgC4lU
# W9Kd7GYiVXULmxQPA3eRQdsAUpZVEZEN75C51EQTFuHHDoGSevt0g1RGFrmvoo9X
# FFnXTAlFvZl2uynaEY1bjl4klh7V7Y1RJaWHGOKSOsb/YU/dSrwtZur/ZA==
# SIG # End signature block
