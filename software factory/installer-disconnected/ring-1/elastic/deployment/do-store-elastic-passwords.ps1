param (
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $AdminUsername,
    [Parameter(Mandatory=$true)] [string] $SshOptions,
    [Parameter(Mandatory=$false)] [string] $BastionIpAddress,
    [Parameter(Mandatory=$true)] [string] $ElasticKeyVault
)

Set-LogFile "./deployment-output/store-elastic-passwords_$(Get-Date -format `"yyyy-MM-dd-HHmmss`").log"
Log-ScriptHeader -ScriptName $MyInvocation.MyCommand -ScriptArgs $MyInvocation.MyCommand.Parameters

$argListBase = "$SshOptions $AdminUsername`@$BastionIpAddress"

$argList = "$argListBase `"sudo cat /etc/elasticsearch/userdest/elastic`""
$elasticPassword = Run-Command -Process "ssh" -Arguments $argList -AlsoReturnCmdOutput -SupressOutput

$argList = "keyvault secret set --vault-name $ElasticKeyVault -n elasticPassword --value `"$($elasticPassword[1])`""
$retVal = Run-Command -Process "az" -Arguments $argList


$argList = "$argListBase `"sudo cat /etc/elasticsearch/userdest/apm_system`""
$apmSystemPassword = Run-Command -Process "ssh" -Arguments $argList -AlsoReturnCmdOutput -SupressOutput

$argList = "keyvault secret set --vault-name $ElasticKeyVault -n apmSystemPassword --value `"$($apmSystemPassword[1])`""
$retVal = Run-Command -Process "az" -Arguments $argList


$argList = "$argListBase `"sudo cat /etc/elasticsearch/userdest/kibana`""
$kibanaPassword = Run-Command -Process "ssh" -Arguments $argList -AlsoReturnCmdOutput -SupressOutput

$argList = "keyvault secret set --vault-name $ElasticKeyVault -n kibanaPassword --value `"$($kibanaPassword[1])`""
$retVal = Run-Command -Process "az" -Arguments $argList


$argList = "$argListBase `"sudo cat /etc/elasticsearch/userdest/logstash_system`""
$logstashPassword = Run-Command -Process "ssh" -Arguments $argList -AlsoReturnCmdOutput -SupressOutput

$argList = "keyvault secret set --vault-name $ElasticKeyVault -n logstashPassword --value `"$($logstashPassword[1])`""
$retVal = Run-Command -Process "az" -Arguments $argList


$argList = "$argListBase `"sudo cat /etc/elasticsearch/userdest/beats_system`""
$beatsPassword = Run-Command -Process "ssh" -Arguments $argList -AlsoReturnCmdOutput -SupressOutput

$argList = "keyvault secret set --vault-name $ElasticKeyVault -n beatsPassword --value `"$($beatsPassword[1])`""
$retVal = Run-Command -Process "az" -Arguments $argList


$argList = "$argListBase `"sudo cat /etc/elasticsearch/userdest/remote_monitoring_user`""
$remoteMonitoringPassword = Run-Command -Process "ssh" -Arguments $argList -AlsoReturnCmdOutput -SupressOutput

$argList = "keyvault secret set --vault-name $ElasticKeyVault -n remoteMonitoringPassword --value `"$($remoteMonitoringPassword[1])`""
$retVal = Run-Command -Process "az" -Arguments $argList


Log-ScriptEnd







# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUj/GHV/99ymZalidaptorg3uI
# HWugggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBQ/HB474ltL7Ffzb40USC2skxt57jANBgkqhkiG
# 9w0BAQEFAASCAgAQPDu4uv9aR60AhcMHaZi8YHJ3KjCx362tGNAJnB+n2tQEZl7r
# Ipmh5Jf6aXf+FKlsBv1AXUYBM0NNO4dsT2VqSb2VE7Q9KSLppAPlYpda4P7ZU4CM
# 6fpG/N1zKYDF+cr7Eptp9x2ZEG0njiRo4TdYOiFdCQ7RZb5TmAtKnYsSoV91TlUp
# +wXDbkJVwXrz7Enjp4lKN8DFNsw7SZgC/ti25bn4WFrLA/5kMTRtfsqONGTxHquy
# EjcVhvXRU4/rBq8FU657FJ0CJHJG+HfgTq/4jEv5p6hsa63fVjYO/9R61e/vpXqt
# ad2GugESSM/4cPovSjo92FRSYzJMwyJLE585Z9u0pR+bdDEorh58ObwRFIsknpG/
# 6J9PENV5lsdSatLa+pisQjzD7qEvVqSEK54bJHEyQp7L556XXQMVnP00sB+cYcKM
# cFTJ5+W83Dvg57ud5jFb+/SQ671F9QtHf7ICYlTQP4QorFM0/SbBRmfa3vZSFV3J
# iCzpRJ1eRyuNGRXfYhaq76l/6LkK5hI0+3uFIXJFYf+rTdSJ+3XeR3AhEdZOZgut
# DV2E81zwtEusHvkhezbxWn99qXmB/7VCNnWcZOw9RmlhKQnRtxNKZdn/FOUCJ/2K
# VBKnh0oh78afHAi2ZLepf+rpoq8zRc2IQgI0PEyzxm4eh6RhOjVCEjk7Jg==
# SIG # End signature block
