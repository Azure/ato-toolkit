#region script variables
[string] $DeploymentEnumFile = ".\DeploymentTypeEnum.ps1"
[string] $LocalVarFile = ".\deployment.vars.ps1"
[string] $LogFilePath = ".\deployment-output\"
[string] $RedactString = "***"
#endregion

# ingest local var file; needed in case this runs as a standalone script
if (-not (Test-Path $LocalVarFile))
{
    throw "Cannot find $LocalVarFile.  Unable to sanitize logs."
}

if (-not (Test-Path $DeploymentEnumFile))
{
    throw "Cannot find $DeploymentEnumFile.  Unable to sanitize logs."
}

Write-Output "Scrubbing Logs."

Write-Output "Loading dependencies"
# Load dependencies
. $DeploymentEnumFile
. $LocalVarFile

# Search patterns
[array] $RegexPatterns = "((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)",
                        $ProductLine,
                        $Environment,
                        $RegionLocation 


Write-Output "Finding log files."
# read log files

$allLogFiles = Get-childitem $LogFilePath -recurse | Select-Object -expand fullname
Write-Output "Found $($allLogFiles.Count) logs to sanitize."

foreach ($logFile in $allLogFiles)
{ 
    $logContents = Get-Content $logfile
    foreach ($regex in $RegexPatterns)
    {
        $logContents = $logContents -replace $regex, $RedactString
    }
    $logContents | Set-Content $logFile
}

Write-Output "Finished sanitizing logs."
Write-Output "Please review files before exporting."






# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUv1cr6WKJ/g6CQ0JhbOswRSAm
# Nt6gggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBQAMTusevGHndUAM2iG9ZhYih1mWjANBgkqhkiG
# 9w0BAQEFAASCAgBbx7yS/Urm0Fqt2YRLy813CduyClg9HgCdMvFfH3k0Unqn2Rmu
# xOdtoIWkSoJjRDLGdw+KccZdkZuFCHK/1fhbRAG75udRf+wF90+gWyHoh9VQEN6p
# wRZR3Y+iytXmDQN8wSFGCsMlNQ1eL9xzx3Gg1sGbPDbJ+TwUodrrdKV43yTyaP1s
# OReCXyzCkqY8b6vu7fyiRtO8aJxfYRVDzM8xnP6yH0o1fGgB6mr9/79/AqLyWGrZ
# sRl8u7RYBmFDxMfgCCP/IBQBAzdc0k4XMAtFDSEsnH7rCOTb9T46uAQozhL+lNmy
# yhVe74rveSYwMItoUPqytLn7eoUKb4HhUhwScTVfTcFLxRD5XvoYmVrHMvF/DwE0
# LGl/+D3yoiau++Uu27cIxW0ODrtRvq5t23jKTkFGPwGVWAK8zX/YRfnynT5Ztbty
# xR2V4coSTP4UhlKlxVD+Xb0zsYu9dHe+MTCgJ/ZKttsruUbziWCrnUxyt8fVxAiR
# hSDD5/Y3Cv/fw6wPNexl6Mg+YwLfixP1BqfogwgQaI4STEmx1p5IgLy+InY/4rId
# 18BKAFNTkuSDaz1latxNYs8UCa+ebl6LLM/cSWCDoM+pChOS0pJyqR+cBYiExoKL
# ZSc4jvgxoXdbOO6X9jRWpFpK5AtaF2I9Qd/ThjwfIjF9jlauPGqE6Oqvuw==
# SIG # End signature block
