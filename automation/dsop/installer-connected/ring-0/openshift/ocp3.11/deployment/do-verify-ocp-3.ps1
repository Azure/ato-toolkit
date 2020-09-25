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

Log-Parameters -ScriptName $MyInvocation.MyCommand -ScriptArgs $MyInvocation.MyCommand.Parameters

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

Log-Information "checking dnsmasq"
Set-EncodedJsonFile -Command "sudo cat /etc/dnsmasq.conf"
New-AzureLinuxExtension -ResourceGroup $ResourceGroup -VmName $MasterOneHostname -JsonFile $Script:jsonFile
Get-AzureLinuxExtensionMessageOutput -ResourceGroup $ResourceGroup -VmName $MasterOneHostname

Log-Information "checking ansible hosts"
Set-EncodedJsonFile -Command "sudo cat /etc/ansible/hosts"
New-AzureLinuxExtension -ResourceGroup $ResourceGroup -VmName $MasterOneHostname -JsonFile $Script:jsonFile
Get-AzureLinuxExtensionMessageOutput -ResourceGroup $ResourceGroup -VmName $MasterOneHostname

Log-Information "checking entropy"
Set-EncodedJsonFile -Command "sudo cat /proc/sys/kernel/random/entropy_avail"
New-AzureLinuxExtension -ResourceGroup $ResourceGroup -VmName $MasterOneHostname -JsonFile $Script:jsonFile
Get-AzureLinuxExtensionMessageOutput -ResourceGroup $ResourceGroup -VmName $MasterOneHostname

Log-Information "checking router config"
Set-EncodedJsonFile -Command "sudo oc -n default get deploymentconfigs/router"
New-AzureLinuxExtension -ResourceGroup $ResourceGroup -VmName $MasterOneHostname -JsonFile $Script:jsonFile
Get-AzureLinuxExtensionMessageOutput -ResourceGroup $ResourceGroup -VmName $MasterOneHostname

Log-Information "checking docker registry"
Set-EncodedJsonFile -Command "sudo oc -n default get deploymentconfigs/docker-registry"
New-AzureLinuxExtension -ResourceGroup $ResourceGroup -VmName $MasterOneHostname -JsonFile $Script:jsonFile
Get-AzureLinuxExtensionMessageOutput -ResourceGroup $ResourceGroup -VmName $MasterOneHostname

Log-Information "checking pods wide"
Set-EncodedJsonFile -Command "sudo oc -n default get pods -o wide"
New-AzureLinuxExtension -ResourceGroup $ResourceGroup -VmName $MasterOneHostname -JsonFile $Script:jsonFile
Get-AzureLinuxExtensionMessageOutput -ResourceGroup $ResourceGroup -VmName $MasterOneHostname

Log-Information "checking for holes"
Set-EncodedJsonFile -Command "sudo dig *.$RoutingSubDomain"
New-AzureLinuxExtension -ResourceGroup $ResourceGroup -VmName $MasterOneHostname -JsonFile $Script:jsonFile
Get-AzureLinuxExtensionMessageOutput -ResourceGroup $ResourceGroup -VmName $MasterOneHostname

Log-Information "checking space"
Set-EncodedJsonFile -Command "sudo df -hT"
New-AzureLinuxExtension -ResourceGroup $ResourceGroup -VmName $MasterOneHostname -JsonFile $Script:jsonFile
Get-AzureLinuxExtensionMessageOutput -ResourceGroup $ResourceGroup -VmName $MasterOneHostname

Log-Information "checking docker storage"
Set-EncodedJsonFile -Command "sudo cat /etc/sysconfig/docker-storage"
New-AzureLinuxExtension -ResourceGroup $ResourceGroup -VmName $MasterOneHostname -JsonFile $Script:jsonFile
Get-AzureLinuxExtensionMessageOutput -ResourceGroup $ResourceGroup -VmName $MasterOneHostname

Log-Information "checking docker info"
Set-EncodedJsonFile -Command "sudo docker info"
New-AzureLinuxExtension -ResourceGroup $ResourceGroup -VmName $MasterOneHostname -JsonFile $Script:jsonFile
Get-AzureLinuxExtensionMessageOutput -ResourceGroup $ResourceGroup -VmName $MasterOneHostname

Log-Information "checking oc api"
Set-EncodedJsonFile -Command "sudo oc get pod -n kube-system -o wide"
New-AzureLinuxExtension -ResourceGroup $ResourceGroup -VmName $MasterOneHostname -JsonFile $Script:jsonFile
Get-AzureLinuxExtensionMessageOutput -ResourceGroup $ResourceGroup -VmName $MasterOneHostname

Log-Information "checking oc config"
Set-EncodedJsonFile -Command "sudo oc get -n kube-system cm openshift-master-controllers -o yaml"
New-AzureLinuxExtension -ResourceGroup $ResourceGroup -VmName $MasterOneHostname -JsonFile $Script:jsonFile
Get-AzureLinuxExtensionMessageOutput -ResourceGroup $ResourceGroup -VmName $MasterOneHostname

Log-Information "checking oc k8s service"
Set-EncodedJsonFile -Command "sudo oc describe svc kubernetes -n default"
New-AzureLinuxExtension -ResourceGroup $ResourceGroup -VmName $MasterOneHostname -JsonFile $Script:jsonFile
Get-AzureLinuxExtensionMessageOutput -ResourceGroup $ResourceGroup -VmName $MasterOneHostname

Log-Footer -ScriptName $MyInvocation.MyCommand
