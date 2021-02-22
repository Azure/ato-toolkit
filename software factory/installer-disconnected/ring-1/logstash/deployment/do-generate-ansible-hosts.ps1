param (
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $LogstashHostname,
    [Parameter(Mandatory=$true)] [int] $Nodes,
    [Parameter(Mandatory=$true)] [string] $AdminUsername,
    [Parameter(Mandatory=$true)] [string] $SshKey,
    [Parameter(Mandatory=$false)] [string] $AnsibleHosts = "./ansible/hosts"
)

# NEITHER OF THESE VALUES MUST BE < 32 GB RAM
# JVM suggested heap size. Must be 50% of VM RAM size. Default value is for an 8GB VM
$jvm1 = "jvm1=-Xms4g"
# JVM max heap size. Must be 50% of VM RAM size. Default value is for an 8GB VM
$jvm2 = "jvm2=-Xmx4g"

Set-Content -Path $AnsibleHosts -Value "[logstash]"
for ($i = 1; $i -le $Nodes; $i++) {
    $hostname = "$LogstashHostname-00$($i)v"
    $ipAddress=( az vm show -g $ResourceGroup -n $hostname -d --query privateIps -o tsv )
    Add-Content -Path $AnsibleHosts -Value "$hostname ansible_host=$ipAddress ansible_ssh_user=$AdminUsername ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' ansible_ssh_private_key_file=$SshKey $jvm1 $jvm2"
}





# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUnnDFPvy9UVltVYlKNtw0T8cv
# 6wWgggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBTVOoWaG8VAvb+wBrM8dopGFj3OoDANBgkqhkiG
# 9w0BAQEFAASCAgBANgtny7+uuPODKSE2/h1K2w61q0PHBiWIFU4nR2qMmWZMPUOs
# vA4pZA4b6gNEy+W3WYuXIfT0drVfWv/YIjF4uDwpM47r+Isa+W8lojP/RT4WoXAR
# sVccArGi3b1dgmA2qnOZg363RG10YUlfrh794ce8AQPCClgLJH62JfmbA6FO7veH
# oVnwhTNiZBRFKqkl8atJGur8l6qFbvCNfN3vH26wu4m/hgccGiCERqT49QWY167L
# rDAHZjO0h0FFdzMJY9Y/iqdUuUkQfHtCgfMRDdU6U6x2kbdptghinIvxIx0LUpUs
# GRFSs/uId06gcHHKhBt6IbsW/SjvluNqfm15nMJQ0Ms0mNwqNfV4wwwE0ikCpTZj
# W5ZaBEcFqG16x2iQ0A7hBNI3q80xJ+4LWFJqcDwr52on0WVnIiHiPeNDo7kpIpoh
# IVg4lIiDqr887jRScie0fpGU7BCJz0C7ZvX/5gssd2PZ5Sqaz84rsoK5Ddv+Z/qc
# NzF2q5naDlj61zvVAZ5PN6MdgwWDGSze9bxZDtkU7fKALpeAdktHVNR5qp42Ytwf
# FI3qeZiJb3+P7nHthB3dBI1zOG+QJ5k/MSUhq4ZgQaES+Q+SU4DpH9qTSQjFJ0BB
# Z1dLRfXzj6foHBxWAb7oU2EqEBX79jxArwo6//toO2c4r3Iqo//1N79JaA==
# SIG # End signature block
