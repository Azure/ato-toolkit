param (
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $MasterOneHostname,
    [Parameter(Mandatory=$true)] [string] $BastionOneHostname,
    [Parameter(Mandatory=$true)] [string] $RoutingSubDomain
)


function Set-EncodedJsonFile
{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Command
    )

    $encodedScript = Get-Base64EncodedString -StringToEncode $Command

    Set-Content -Path $Script:jsonFile -Value "{`"script`": `"$encodedScript`"}"
}


$Script:jsonFile = "$($(Get-Location).Path)/validateocp.json"

Log-ScriptHeader -ScriptName $MyInvocation.MyCommand -ScriptArgs $MyInvocation.MyCommand.Parameters

# https://docs.openshift.com/container-platform/3.11/day_two_guide/run_once_tasks.html
# https://docs.openshift.com/container-platform/3.11/day_two_guide/environment_health_checks.html

Log-Information "checking on the pods"
# need a command that gives a completion state and writes to stdout to get status
Set-EncodedJsonFile -Command "sudo oc get pods --all-namespaces"
New-AzureLinuxExtension -ResourceGroup $ResourceGroup -VmName $MasterOneHostname -JsonFile $Script:jsonFile
Get-AzureLinuxExtensionMessageOutput -ResourceGroup $ResourceGroup -VmName $MasterOneHostname

Log-Information "checking oc status"
Set-EncodedJsonFile -Command "sudo oc status"
New-AzureLinuxExtension -ResourceGroup $ResourceGroup -VmName $MasterOneHostname -JsonFile $Script:jsonFile
Get-AzureLinuxExtensionMessageOutput -ResourceGroup $ResourceGroup -VmName $MasterOneHostname

Log-Information "checking all oc"
Set-EncodedJsonFile -Command "sudo oc get all"
New-AzureLinuxExtension -ResourceGroup $ResourceGroup -VmName $MasterOneHostname -JsonFile $Script:jsonFile
Get-AzureLinuxExtensionMessageOutput -ResourceGroup $ResourceGroup -VmName $MasterOneHostname

Log-Information "checking storage class"
Set-EncodedJsonFile -Command "sudo kubectl get storageclass"
New-AzureLinuxExtension -ResourceGroup $ResourceGroup -VmName $MasterOneHostname -JsonFile $Script:jsonFile
Get-AzureLinuxExtensionMessageOutput -ResourceGroup $ResourceGroup -VmName $MasterOneHostname
# auto confirm the glusterfs-storage is default
# NAME                          PROVISIONER               AGE
# glusterfs-storage (default)   kubernetes.io/glusterfs   1h

Log-Information "checking dnsmasq"
Set-EncodedJsonFile -Command "sudo cat /etc/dnsmasq.conf"
New-AzureLinuxExtension -ResourceGroup $ResourceGroup -VmName $MasterOneHostname -JsonFile $Script:jsonFile
Get-AzureLinuxExtensionMessageOutput -ResourceGroup $ResourceGroup -VmName $MasterOneHostname
# auto confirm the ending of the file has the two lines we added is default

Log-Information "checking ansible hosts"
Set-EncodedJsonFile -Command "sudo cat /etc/ansible/hosts"
New-AzureLinuxExtension -ResourceGroup $ResourceGroup -VmName $MasterOneHostname -JsonFile $Script:jsonFile
Get-AzureLinuxExtensionMessageOutput -ResourceGroup $ResourceGroup -VmName $MasterOneHostname
# auto confirm something

Log-Information "checking entropy"
Set-EncodedJsonFile -Command "sudo cat /proc/sys/kernel/random/entropy_avail"
New-AzureLinuxExtension -ResourceGroup $ResourceGroup -VmName $MasterOneHostname -JsonFile $Script:jsonFile
Get-AzureLinuxExtensionMessageOutput -ResourceGroup $ResourceGroup -VmName $MasterOneHostname
# auto confirm the number is higher than 1000

Log-Information "checking router config"
Set-EncodedJsonFile -Command "sudo oc -n default get deploymentconfigs/router"
New-AzureLinuxExtension -ResourceGroup $ResourceGroup -VmName $MasterOneHostname -JsonFile $Script:jsonFile
Get-AzureLinuxExtensionMessageOutput -ResourceGroup $ResourceGroup -VmName $MasterOneHostname
# The values in the DESIRED and CURRENT columns should match the number of nodes hosts

Log-Information "checking docker registry"
Set-EncodedJsonFile -Command "sudo oc -n default get deploymentconfigs/docker-registry"
New-AzureLinuxExtension -ResourceGroup $ResourceGroup -VmName $MasterOneHostname -JsonFile $Script:jsonFile
Get-AzureLinuxExtensionMessageOutput -ResourceGroup $ResourceGroup -VmName $MasterOneHostname
# The values in the DESIRED and CURRENT columns should match the number of nodes hosts

Log-Information "checking pods wide"
Set-EncodedJsonFile -Command "sudo oc -n default get pods -o wide"
New-AzureLinuxExtension -ResourceGroup $ResourceGroup -VmName $MasterOneHostname -JsonFile $Script:jsonFile
Get-AzureLinuxExtensionMessageOutput -ResourceGroup $ResourceGroup -VmName $MasterOneHostname

# Log-Information "checking the cluster version"
# az vm run-command invoke -g $ResourceGroup -n $MasterOneHostname --command-id RunShellScript --scripts "curl -k https://beta1-master01.beta1-openshift.com:443/version" -o table
# need to verify the output
# {
#   "major": "1",
#   "minor": "6",
#   "gitVersion": "v1.6.1+5115d708d7",
#   "gitCommit": "fff65cf",
#   "gitTreeState": "clean",
#   "buildDate": "2017-10-11T22:44:25Z",
#   "goVersion": "go1.7.6",
#   "compiler": "gc",
#   "platform": "linux/amd64"
# }

# Log-Information "checking the healthz"
# az vm run-command invoke -g $ResourceGroup -n $MasterOneHostname --command-id RunShellScript --scripts "sudo curl -k https://master.example.com:443/healthz" --query "{Message:value[0].message}" -o table
# # verify it resturns ok

Log-Information "checking for holes"
Set-EncodedJsonFile -Command "sudo dig *.$RoutingSubDomain"
New-AzureLinuxExtension -ResourceGroup $ResourceGroup -VmName $MasterOneHostname -JsonFile $Script:jsonFile
Get-AzureLinuxExtensionMessageOutput -ResourceGroup $ResourceGroup -VmName $MasterOneHostname
# confirm the dig output
# [ocpadmin@beta1-master01 ~]$ dig *.apps.beta-openshift.com

# ; <<>> DiG 9.11.4-P2-RedHat-9.11.4-9.P2.el7 <<>> *.apps.beta-openshift.com
# ;; global options: +cmd
# ;; Got answer:
# ;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 52012
# ;; flags: qr rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1

# ;; OPT PSEUDOSECTION:
# ; EDNS: version: 0, flags:; udp: 4000
# ; OPT=65436: 28 f4 8b e2 b1 56 f6 4c 86 0f 19 22 26 3f b3 30 ("(....V.L..."&?.0")
# ;; QUESTION SECTION:
# ;*.apps.beta-openshift.com.	IN	A

# ;; AUTHORITY SECTION:
# com.			300	IN	SOA	a.gtld-servers.net. nstld.verisign-grs.com. 1579797764 1800 900 604800 86400

# ;; Query time: 68 msec
# ;; SERVER: 10.3.101.11#53(10.3.101.11)
# ;; WHEN: Thu Jan 23 16:43:04 UTC 2020
# ;; MSG SIZE  rcvd: 147

Log-Information "checking space"
Set-EncodedJsonFile -Command "sudo df -hT"
New-AzureLinuxExtension -ResourceGroup $ResourceGroup -VmName $MasterOneHostname -JsonFile $Script:jsonFile
Get-AzureLinuxExtensionMessageOutput -ResourceGroup $ResourceGroup -VmName $MasterOneHostname
# verify /var/ has at least 40 GB
# Filesystem     Type      Size  Used Avail Use% Mounted on
# devtmpfs       devtmpfs  7.9G     0  7.9G   0% /dev
# tmpfs          tmpfs     7.9G     0  7.9G   0% /dev/shm
# tmpfs          tmpfs     7.9G  3.4M  7.9G   1% /run
# tmpfs          tmpfs     7.9G     0  7.9G   0% /sys/fs/cgroup
# /dev/sda2      xfs        64G  4.5G   60G   8% /
# /dev/sda1      xfs       497M  101M  397M  21% /boot
# /dev/sdb1      ext4       32G  2.1G   28G   7% /mnt/resource
# tmpfs          tmpfs     1.6G     0  1.6G   0% /run/user/1000

Log-Information "checking docker storage"
Set-EncodedJsonFile -Command "sudo cat /etc/sysconfig/docker-storage"
New-AzureLinuxExtension -ResourceGroup $ResourceGroup -VmName $MasterOneHostname -JsonFile $Script:jsonFile
Get-AzureLinuxExtensionMessageOutput -ResourceGroup $ResourceGroup -VmName $MasterOneHostname
# verify DOCKER_STORAGE_OPTIONS='--storage-driver overlay2'

Log-Information "checking docker info"
Set-EncodedJsonFile -Command "sudo docker info"
New-AzureLinuxExtension -ResourceGroup $ResourceGroup -VmName $MasterOneHostname -JsonFile $Script:jsonFile
Get-AzureLinuxExtensionMessageOutput -ResourceGroup $ResourceGroup -VmName $MasterOneHostname
# verify
# Containers: 4
#  Running: 4
#  Paused: 0
#  Stopped: 0
# Images: 4
# Server Version: 1.12.6
# Storage Driver: overlay2
#  Backing Filesystem: xfs
# Logging Driver: journald
# Cgroup Driver: systemd
# Plugins:
#  Volume: local
#  Network: overlay host bridge null
#  Authorization: rhel-push-plugin
# Swarm: inactive
# Runtimes: docker-runc runc
# Default Runtime: docker-runc
# Security Options: seccomp selinux
# Kernel Version: 3.10.0-693.11.1.el7.x86_64
# Operating System: Employee SKU
# OSType: linux
# Architecture: x86_64
# Number of Docker Hooks: 3
# CPUs: 2
# Total Memory: 7.147 GiB
# Name: ocp-infra-node-1clj
# ID: T7T6:IQTG:WTUX:7BRU:5FI4:XUL5:PAAM:4SLW:NWKL:WU2V:NQOW:JPHC
# Docker Root Dir: /var/lib/docker
# Debug Mode (client): false
# Debug Mode (server): false
# Registry: https://registry.redhat.io/v1/
# WARNING: bridge-nf-call-iptables is disabled
# WARNING: bridge-nf-call-ip6tables is disabled
# Insecure Registries:
#  127.0.0.0/8
# Registries: registry.redhat.io (secure), registry.redhat.io (secure), docker.io (secure)

Log-Information "checking oc api"
Set-EncodedJsonFile -Command "sudo oc get pod -n kube-system -o wide"
New-AzureLinuxExtension -ResourceGroup $ResourceGroup -VmName $MasterOneHostname -JsonFile $Script:jsonFile
Get-AzureLinuxExtensionMessageOutput -ResourceGroup $ResourceGroup -VmName $MasterOneHostname
# NAME                                READY     STATUS    RESTARTS   AGE       IP            NODE             NOMINATED NODE
# master-api-beta1-master01           1/1       Running   1          1h        10.3.101.11   beta1-master01   <none>
# master-api-beta1-master02           1/1       Running   0          1h        10.3.101.12   beta1-master02   <none>
# master-api-beta1-master03           1/1       Running   0          1h        10.3.101.9    beta1-master03   <none>
# master-controllers-beta1-master01   1/1       Running   0          1h        10.3.101.11   beta1-master01   <none>
# master-controllers-beta1-master02   1/1       Running   0          1h        10.3.101.12   beta1-master02   <none>
# master-controllers-beta1-master03   1/1       Running   0          1h        10.3.101.9    beta1-master03   <none>
# master-etcd-beta1-master01          1/1       Running   0          1h        10.3.101.11   beta1-master01   <none>
# master-etcd-beta1-master02          1/1       Running   0          1h        10.3.101.12   beta1-master02   <none>
# master-etcd-beta1-master03          1/1       Running   0          1h        10.3.101.9    beta1-master03   <none>
# master-api-myserver.com                            1/1       Running   0          7h        10.240.0.16   myserver.com/healthz

Log-Information "checking oc config"
Set-EncodedJsonFile -Command "sudo oc get -n kube-system cm openshift-master-controllers -o yaml"
New-AzureLinuxExtension -ResourceGroup $ResourceGroup -VmName $MasterOneHostname -JsonFile $Script:jsonFile
Get-AzureLinuxExtensionMessageOutput -ResourceGroup $ResourceGroup -VmName $MasterOneHostname
# apiVersion: v1
# kind: ConfigMap
# metadata:
#   annotations:
#     control-plane.alpha.kubernetes.io/leader: '{"holderIdentity":"beta1-master03","leaseDurationSeconds":15,"acquireTime":"2020-01-23T15:04:37Z","renewTime":"2020-01-23T16:54:31Z","leaderTransitions":0}'
#   creationTimestamp: "2020-01-23T15:04:40Z"
#   name: openshift-master-controllers
#   namespace: kube-system
#   resourceVersion: "25214"
#   selfLink: /api/v1/namespaces/kube-system/configmaps/openshift-master-controllers
#   uid: ae009fe2-3df1-11ea-a0cf-000d3a1db54d

Log-Information "checking oc k8s service"
Set-EncodedJsonFile -Command "sudo oc describe svc kubernetes -n default"
New-AzureLinuxExtension -ResourceGroup $ResourceGroup -VmName $MasterOneHostname -JsonFile $Script:jsonFile
Get-AzureLinuxExtensionMessageOutput -ResourceGroup $ResourceGroup -VmName $MasterOneHostname
# Name:              kubernetes
# Namespace:         default
# Labels:            component=apiserver
#                    provider=kubernetes
# Annotations:       <none>
# Selector:          <none>
# Type:              ClusterIP
# IP:                172.30.0.1
# Port:              https  443/TCP
# TargetPort:        443/TCP
# Endpoints:         10.3.101.11:443,10.3.101.12:443,10.3.101.9:443
# Port:              dns  53/UDP
# TargetPort:        8053/UDP
# Endpoints:         10.3.101.11:8053,10.3.101.12:8053,10.3.101.9:8053
# Port:              dns-tcp  53/TCP
# TargetPort:        8053/TCP
# Endpoints:         10.3.101.11:8053,10.3.101.12:8053,10.3.101.9:8053
# Session Affinity:  None
# Events:            <none>

Log-Footer -ScriptName $MyInvocation.MyCommand







# SIG # Begin signature block
# MIIIZwYJKoZIhvcNAQcCoIIIWDCCCFQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUlbkO5u46EDqmn0TI1fU0sqj1
# J8ygggUEMIIFADCCAuigAwIBAgIQFaxo6DEMNq5Bd3mHM4/5BzANBgkqhkiG9w0B
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
# AgEVMCMGCSqGSIb3DQEJBDEWBBSNy06haP/xOyh2NWIGQS17ZtcokDANBgkqhkiG
# 9w0BAQEFAASCAgBa5loMBU2fBMnAtDVtR3UU5sFaYNgUYrYP4ONu+Kt9N+7Q+YGA
# HYvl+QerrijumCNVoc89jqf/vi2mCgJF4NBcOd1/++F8tCd01moScc21AXpgZkfT
# YEjbV97XCVXIts93v5CMqnLUFCRV4paXfiO2RGrosV9g1FVKiEN2W3kSnQIwr/bf
# yUiSA0OOgoFT0oVPP6rUyFnMaEXEfec4GUpGe9msRmEVgJS1r8IQ1306DBahpJ1r
# IgXgw4l5p+yeVbc4TadK/Bvn9QXIMAiZUbYQiVGmbrp8ZgTC7nF8Nvo/I2DdFNJv
# L9jthdrQHWaLGtAoOvZ4QqTl+muQBk1Ss0d7gFHMLgg8MdxKYSTXnK3rhQps0ZB7
# tKxwg6G/4sFCItBAA1pE/DwWuRypJq1r5mm4co3EjBTdKwHz8dufynqUc+5bNlQn
# yNzRZiMl7pu97yTBPnB1TjxpS4kYxssCAub/pzEKr1oPdqeQepnShLTXufEQuw/Y
# +AXKlHciQRDM1CLKJIcMsCm6Qbfu1Ll1odm93c/PXsCvymqgk+xjk5Sgo5SEPfg5
# ydGHtZx9cA3tvpmqaLypIDMBfkZq2swsoOYvmA2tXUfx9SkfH2DAwC7IS8qLkAQQ
# wjKu/YwCOHKRXZFv9jOBNMsZmOAY6d9/DoqUbkckXw40rjezwlgSxM5wEA==
# SIG # End signature block
