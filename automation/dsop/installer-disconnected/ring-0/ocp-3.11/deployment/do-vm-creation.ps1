param (
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $AzureLocation,
    [Parameter(Mandatory=$true)] [string] $DiagnosticsStorage,
    [Parameter(Mandatory=$true)] [string] $AdminUsername,
    [Parameter(Mandatory=$true)] [string] $SshKey,
    [Parameter(Mandatory=$true)] [string] $SubnetName,
    [Parameter(Mandatory=$true)] [int] $MachineNumber,
    [Parameter(Mandatory=$true)] [int] $DataDiskSize,
    [Parameter(Mandatory=$true)] [string] $MachineNamePrefix,
    [Parameter(Mandatory=$true)] [string] $NetworkSecurityGroup,
    [Parameter(Mandatory=$true)] [string] $MarketplacePublisher,
    [Parameter(Mandatory=$true)] [string] $MarketplaceOffer,
    [Parameter(Mandatory=$true)] [string] $MarketplaceSku,
    [Parameter(Mandatory=$true)] [string] $MarketplaceVersion,
    [Parameter(Mandatory=$true)] [string] $VmSize,
    [Parameter(Mandatory=$true)] [string] $LogFile,
    [Parameter(Mandatory=$true)] [string] $OsImageType,
    [Parameter(Mandatory=$true)] [string] $VhdImageName,
    # Optional Params
    [string] $AvailabilitySet,
    [string] $LoadBalancerName,
    [string] $LoadBalancerBackEnd,
    [int] $CnsGlusterDiskSize,
    [string] $PublicIpName
)

Set-LogFile -LogFile $LogFile

Log-ScriptHeader -ScriptName $MyInvocation.MyCommand -ScriptArgs $MyInvocation.MyCommand.Parameters

$proc = "az"

$MachineNumberPadded = ([string]$MachineNumber).PadLeft(3,'0')

$vmName = "$MachineNamePrefix-$($MachineNumberPadded)v"
$osDiskName = "$MachineNamePrefix-$($MachineNumberPadded)v-OSDISK"
$nicName = "$MachineNamePrefix-$($MachineNumberPadded)v-NIC-001"
$dockerDataDisk = "$MachineNamePrefix-$($MachineNumberPadded)v-DOCKER-POOL"

Log-Information "create the nic"
$argList = "network nic create -n $nicName " +
            "-g $ResourceGroup " +
            "--subnet $SubnetName " +
            "--network-security-group $NetworkSecurityGroup " +
            "-o table "

if ($PublicIpName)
{
    $publicIpArgList = "network public-ip create -g $ResourceGroup -n $PublicIpName"
    $retVal = Run-Command -Process $proc -Arguments $publicIpArgList

    # add to the arg list for creating the nic
    $argList += "--public-ip-address `"$PublicIpName`" "
}

if ($LoadBalancerName) {
    $argList += "--lb-name $LoadBalancerName --lb-address-pool $LoadBalancerBackEnd "
}

$retVal = Run-Command -Process $proc -Arguments $argList

Log-Information "create the vm with encrypted os disk"
$argList = "vm create -g $ResourceGroup " +
            "-n $vmName " +
            "--location `"$AzureLocation`" " +
            "--admin-username $AdminUsername " +
            "--size $VmSize " +
            "--os-disk-name $osDiskName " +
            "--os-disk-size-gb 64 " +
            "--boot-diagnostics-storage $DiagnosticsStorage " +
            "--nics $nicName " +
            "--authentication-type ssh " +
            "--generate-ssh-key " +
            "-o table "

if ($AvailabilitySet) {
    $argList += "--availability-set $AvailabilitySet "
}

if ($OsImageType.ToLower() -eq "vhd")
{
    $argList += "--image $VhdImageName "
}
else
{
    $argList += "--image ""$($MarketplacePublisher):$($MarketplaceOffer):$($MarketplaceSku):$($MarketplaceVersion)"" "
}

$retVal = Run-Command -Process $proc -Arguments $argList

Log-Information "create the encrypted docker pool disk"
$argList = "vm disk attach -n $dockerDataDisk " +
            "-g $ResourceGroup " +
            "--size-gb $DataDiskSize " +
            "--sku Standard_LRS " +
            "--new " +
            "--vm-name $vmName " +
            "-o table"
$retVal = Run-Command -Process $proc -Arguments $argList

if ($CnsGlusterDiskSize -gt 0) {
    for ($i = 0; $i -le 2; $i++) {
        $glusterDisk = "$MachineNamePrefix-$($MachineNumberPadded)v-GLUSTER-DISK$($i)"

        Log-Information "Attach the gluster disk $($i)"
        $argList = "vm disk attach --name $glusterDisk " +
                    "-g $ResourceGroup " +
                    "--size-gb $CnsGlusterDiskSize " +
                    "--sku Standard_LRS " +
                    "--new " +
                    "--vm-name $vmName " +
                    "--lun $($i+1) " +
                    "-o table"
        $retVal = Run-Command -Process $proc -Arguments $argList
    }
}

Log-Information "Set the vm ssh key user"
$SshKeyPath = "$($(Get-Location).Path)/certs/$SshKey.pub"
$argList = "vm user update " +
            "--resource-group $ResourceGroup " +
            "--name $vmName " +
            "--username $AdminUsername " +
            "--ssh-key-value $SshKeyPath " +
            "-o table"
$retVal = Run-Command -Process $proc -Arguments $argList

Log-ScriptEnd







# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUK5BQLhsfBUvcF3si2lakqVpO
# seigggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBS21pftmgJGxTHyEtH8x3N1ANMk9jANBgkqhkiG
# 9w0BAQEFAASCAgALQlAUnNY63nxWt/g3uiqE9ltMpSWrCP7Usb9JMHbYmG3uxpks
# JbpUwhuaaVLyQMtXoSwbQzKh94mk2C1u1Ggi1aFdzeXS0uJEqV+OZRmiNpPgjQ2h
# syr6pjNkQq5+LBrUrqwCEWgLbfEEbo/uVxncw40pijIORQp2ltHnNBRh3kbAt25z
# pKCHdABrYeW/x72wffKABeyo9OR1XazCp4gbHU7sgmBBvaHXXk9SD6qVWdI4Hnql
# Vb3VEoyN7FtYUEnVIsOWOh+CXhgJuJctWcAzLKbdI1Lhbt7t+V5rY4DU2HapCIrW
# /dO0KcUF04E/u9ob5UT53kSGU0V9gPmSMgp45ATQJ3GLBlTQOYmt0EbujKX4rzVP
# vmSem6UM+ogu5ujCtPNc5QxctWTLFqhf1MqXx9VXAVWNJ7WBuyjJm4A/0/ghKaMP
# 18vY1Uc2aUV1eqLT5xrLAcYKgN8aFVeC0dZgqM9sq23NmGZ1218J5rrix8gCvf3X
# aW8ryZqPSd01Wz/RNJDHd9SbhW+pbI8mfKtX0JVHecMfLioLSkpd1hudp3TTbuN2
# FsBuWi5ngEi4tcOCqF+YvjKIdKfYQ8kQHZtXslY9xIs7KdfGeI/NoVXsi2wmeP+m
# ekmNhZPCzyNEe0uDSaIy9YUXq7Pn4a8hykrXMEfUKJwNDOFs5TzX9rojVg==
# SIG # End signature block
