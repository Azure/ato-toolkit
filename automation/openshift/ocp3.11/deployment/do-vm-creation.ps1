param (
    [Parameter(Mandatory=$true)] [string] $ResourceGroup,
    [Parameter(Mandatory=$true)] [string] $Environment,
    [Parameter(Mandatory=$true)] [string] $RegionLocation,
    [Parameter(Mandatory=$true)] [string] $AzureLocation,
    [Parameter(Mandatory=$true)] [string] $DiagnosticsStorage,
    [Parameter(Mandatory=$true)] [string] $AdminUsername,
    [Parameter(Mandatory=$true)] [string] $SshKey,
    [Parameter(Mandatory=$true)] [string] $SubnetName,
    [Parameter(Mandatory=$true)] [int] $MachineNumber,
    [Parameter(Mandatory=$true)] [int] $DataDiskSize,
    [Parameter(Mandatory=$true)] [string] $MachineTypeShortname,
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

# Import common files
$importFiles = Get-ChildItem "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)\Common\*.ps1"
if ($importFiles.Count -gt 0) {
    foreach ($file in $importFiles) {
        Write-Host "Importing common library [$($file.BaseName)]"
        . $file.FullName
    }
} else {
    Write-Host "This script requires additional modules to be loaded.  Could not find any." -ForegroundColor Red
    Write-Host "Exiting script." -ForegroundColor Red
    exit(1)
}

Log-ScriptHeader -ScriptName $MyInvocation.MyCommand -LogFile $LogFile -ScriptArgs $MyInvocation.MyCommand.Parameters

$proc = "az"

$MachineNumberPadded = ([string]$MachineNumber).PadLeft(3,'0')

$vmName = "$Environment-$RegionLocation-$MachineTypeShortname-$($MachineNumberPadded)v"
$osDiskName = "$Environment-$RegionLocation-$MachineTypeShortname-$($MachineNumberPadded)v-OSDISK"
$nicName = "$Environment-$RegionLocation-$MachineTypeShortname-$($MachineNumberPadded)v-NIC-001"
$dockerDataDisk = "$Environment-$RegionLocation-$MachineTypeShortname-$($MachineNumberPadded)v-DOCKER-POOL"

Log-Information "create the nic for $MachineTypeShortname"
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
        $glusterDisk = "$Environment-$RegionLocation-$MachineTypeShortname-$($MachineNumberPadded)v-GLUSTER-DISK$($i)"

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
