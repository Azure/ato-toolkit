param (
    [ValidateNotNullOrEmpty()]
    [string] $VariableFile = ".\deployment.vars.ps1"
)
$CommonLibraryVersionRequirement = "0.0.1"
$getpwd = Get-Location
$infols = invoke-Expression "ls"
$infolsparent = invoke-Expression "ls .."

if (-not (Test-Path $VariableFile))
{
    Throw "You are in $getpwd \n
    ls info: $infols  \n\nlspar info: $infolsparent"
    Throw "Variable file, $VariableFile, not found.  Please double check the path."
    exit
}

Get-Command Log-Information -ErrorAction SilentlyContinue | Out-Null

$installedModule = Get-Module -Name CloudFit.Dsop.Common
if ($installedModule)
{
    Write-Output "Found CloudFit.Dsop.Common module. Checking version requirements."
    if ($installedModule.Version -ge $CommonLibraryVersionRequirement)
    {
        Write-Output "Found version $($installedModule.Version)"
    }
    else
    {
        throw "$($installedModule.Version) is less than minimum required version: $CommandLibraryVersionRequirement"
    }
}
else
{
    throw "Cannot find CloudFit.Dsop.Common library.  Cannot continue."
}

Set-LogFile -LogFile "./openebsdeployment.log"

$VariableFile = Get-ChildItem $VariableFile
Log-Information "Loading variable file, $VariableFile"
. $VariableFile

Log-Information "Pre install checks complete. Running deployment."
New-Item -Path "./output" -ItemType "directory"
./do-deployment.ps1 @DepArgs | Tee-Object -FilePath ./output/do-openebs.txt






# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUkx/Z7Wk77MMseUCZa6V0sFVr
# oK2gggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBTcxdaeMk6P9BSP4nIymnB6jjxrSjANBgkqhkiG
# 9w0BAQEFAASCAgBY+MUPShveEtfVRso3ibxW8U9sQGVnU3IyE2BwCqAwhxTJTQMK
# ejeXHB/yguXL7j4bPK4w5/AdN/IZlheLlJtFwo4zMHDa26m9da8NfDDnPeNGgATU
# NJRVEH93Ev85qLTXZ5ZCHnyxh5pk//tYNkBipizWcJMCD3JiyMUWWCoWkh9//Tpy
# qNYwNtoDV1whlOdEr4IjFW6K1yAzB0TeYkoLrKkNPwsDMOmpVl1U6/LfOaHJ4HEW
# mxXlpL/5nrzdAZ5rD/aN4oD5K2j/eQFV+Xr28ZgnBJsKYPR3b8cTGVsTXJalSMA6
# dgt4Ss3mTQXiOOU4MKZBBWI5kNIY9Y6jsaFB3nJYPmQfeZCSlTkfSItBB4Q9rH5n
# EB0f1miy0b+Lwzf7zIEtI9g1wDORNfun7fkgrUkojGXNrVH63a2t17g5vFlqE/9Q
# MeRyUaLPvpsb+6FI5DHurfGWuqx14LPpyfSrmCLLchWFrTtzKC8zsjPKRsTkXLHf
# WU7SCQ1QjTS/mOxhLzIbK4B7vMLRQV5KYI8YrvCaYeyCA3y9hhNzTAWJ0NfGDK+N
# 6AmlCFzgDJQx2rdPT2UtETUDJOrcY/oMD7p5x0QyZJMLX/Z32r2ZmjMncFJBtjYE
# wcWNEM6y9xtT+HFINtztImr6+BHN548+7RDY4WY7jsB0zuqbUlOgAYQSVQ==
# SIG # End signature block
