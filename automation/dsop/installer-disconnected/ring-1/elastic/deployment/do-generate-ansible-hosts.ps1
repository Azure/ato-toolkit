param (
    [Parameter(Mandatory=$true)] [string] $MasterHostname,
    [Parameter(Mandatory=$true)] [int] $MasterNodes,
    [Parameter(Mandatory=$true)] [string] $DataHostname,
    [Parameter(Mandatory=$true)] [int] $DataNodes,
    [Parameter(Mandatory=$true)] [string] $AdminUsername,
    [Parameter(Mandatory=$true)] [string] $SshKey,
    [Parameter(Mandatory=$false)] [string] $AnsibleHosts = "./ansible/hosts"
)

Set-LogFile "./deployment-output/deploy-elastic-ansible-hosts_$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"
Log-ScriptHeader -ScriptName $MyInvocation.MyCommand -ScriptArgs $MyInvocation.MyCommand.Parameters

# JVM suggested heap size. Must be 50% of VM RAM size. Default value is for an 8GB VM
$jvm1 = "jvm1=-Xms4g"
# JVM max heap size. Must be 50% of VM RAM size. Default value is for an 8GB VM
$jvm2 = "jvm2=-Xmx4g"

Set-Content -Path $AnsibleHosts -Value "[initial-master-node]"
Add-Content -Path $AnsibleHosts -Value "$MasterHostname-001v ansible_ssh_user=$AdminUsername ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' ansible_ssh_private_key_file=$SshKey $jvm1 $jvm2 masterNode=true dataNode=false"

Add-Content -Path $AnsibleHosts -Value ""
Add-Content -Path $AnsibleHosts -Value "[additional-master-nodes]"
for ($i = 2; $i -le $MasterNodes; $i++) {
    Add-Content -Path $AnsibleHosts -Value "$MasterHostname-00$($i)v ansible_ssh_user=$AdminUsername ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' ansible_ssh_private_key_file=$SshKey $jvm1 $jvm2 masterNode=true dataNode=false"
}

Add-Content -Path $AnsibleHosts -Value ""
Add-Content -Path $AnsibleHosts -Value "[data-nodes]"
for ($i = 1; $i -le $DataNodes; $i++) {
    Add-Content -Path $AnsibleHosts -Value "$DataHostname-00$($i)v ansible_ssh_user=$AdminUsername ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' ansible_ssh_private_key_file=$SshKey $jvm1 $jvm2 masterNode=false dataNode=true"
}

Log-ScriptEnd







# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUFDsAdGjwP8FaHtjqyXTzABrc
# 0bugggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBS97e2eIjHde/osiAASw2LJHck4qDANBgkqhkiG
# 9w0BAQEFAASCAgA1NssIEW5HAGRB6a8kyseG1CSeVLU2jcgYG43rR24pDy3oHalg
# TbbFAtSdIvl3YQ+KUZQAS8/FVK/R+COgWC8plFTN93qnA+tUndHqqOJW43slFmAM
# mudWL3kDKAzXmwBoJm/mdThxOyJMejlI3hcGslikqacMUVMFeYhs2A1HuXrHD9ii
# lguMY/2XSWuy9hzY5H2Rd8Q9525wkp4zJxdQRdvEVstq/RIBOVF6/9Q3jYxsJbTJ
# 9gDSAOS5eU7zRffnNYmc25GLM+sF4AK3nUJqMTlicEnsXuIUykIO2Nd/p7h7mDQj
# Nsz5QeiQgaFfzwLAIRML5SCfW7TVDwwGK8/A7sCbTs8c+SaoUukyq75dpyzYlUQA
# nr8mNwsxzpzxE3RlZ9cK84YgXPO0+9nQkM+bSLku3e8hD9rkmK5uTDJrmpPpSEhM
# NbO879OHv3QC2G0Ta5qT6QdtSIGYnHRqfBCrUQb65jTLw2ShmyyzJOpJaARJTRUc
# ABLq4AsaEUz7HlTN85+bwptsf08nRvpIK/SIleVwbUoiVrL6/3U+ZRMC03TJ5/wj
# jDdyqJM97fwod9mH9yxrtOzwWcOcB18BLVVC0JVricjB8QtomUQzNLAQV4XgJ+R7
# Whq9bthBJUduWwAEWpsSFijrDLQEcivLJo6GXQkvcyRCCwqzaY0EdLIS9Q==
# SIG # End signature block
