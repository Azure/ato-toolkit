#Requires -Module @{ ModuleName = 'Az.Resources'; ModuleVersion = '3.5.0' }
<#
    .SYNOPSIS
        This script enables scaled STIG VM deployment using ATO Tool Kit artifacts.

    .DESCRIPTION
        This script enables scaled STIG VM deployment using ATO Tool Kit artifacts.

    .PARAMETER VmName
        Name of the virtual machine.

    .PARAMETER VmNamePrefix
        Prefix to be used with VmName.

    .PARAMETER VmNameSuffixDelimiter
        Delimiter between VmName and VmNameSuffixStartingNumber.

    .PARAMETER VmNameSuffixStartingNumber
        The starting number for the first VM in the deployment.

    .PARAMETER Count
        Number of unique VMs or VM Availability Sets to deploy.

    .PARAMETER VmSize
        Specifies the size for the virtual machine.

    .PARAMETER OsVersion
        Linux or Windows OS Version.

    .PARAMETER ResourceGroupName
        Specifies the name of the deployment resource group.

    .PARAMETER TemplateUri
        Specifies the URI of a custom template file.

    .PARAMETER Location
        Location for all resources.

    .PARAMETER AdminUserName
        Username for the Virtual Machine.

    .PARAMETER VirtualNetworkNewOrExisting
        Is the Virtual Network new or existing for the Virtual Machine.

    .PARAMETER VmVirtualNetwork
        Virtual Network for the Virtual Machine.

    .PARAMETER VirtualNetworkResourceGroupName
        Name of the resource group for the existing virtual network.

    .PARAMETER AddressPrefix
        Address prefix of the virtual network.

    .PARAMETER SubnetPrefix
        Subnet prefix of the virtual network.

    .PARAMETER SubnetName
        Subnet name for the Virtual Machine.

    .PARAMETER AuthenticationType
        Type of authentication to use on the Virtual Machine, used with Linux deployments, non-applicable for Windows.

    .PARAMETER ArtifactsLocation
        SAS Token to access the storage location containing artifacts.

    .PARAMETER DiagnosticStorageResourceId
        Diagnostic Storage account resource id.

    .PARAMETER LogAnalyticsWorkspaceId
        Log Analytics workspace resource id.

    .PARAMETER OsDiskEncryptionSetResourceId
        OS Disk Encryption Set resource id.

    .PARAMETER ApplicationSecurityGroupResourceId
        Application Security Group resource id.

    .PARAMETER OsDiskStorageType
        Azure managed disks types to support your workload or scenario.

    .PARAMETER CustomData
        Pass a script, configuration file, or other data into the virtual machine while it is being provisioned. The data will be saved on the VM in a known location.

    .PARAMETER AvailabilityOptions
        Determines if an AvailabilitySet is deployed ('availabilitySet' AvailabilitySet is created), ('default' no AvailabilitySet)

    .PARAMETER AvailabilitySetNameSuffix
        AvailabilitySetName Suffix to be used with scaled deployment.

    .PARAMETER InstanceCount
        Number of VMs to deploy per Availability Set.

    .PARAMETER FaultDomains
        Azure fault domains

    .PARAMETER UpdateDomains
        Azure update domains.

    .PARAMETER LogsRetentionInDays
        Log retention in days.

    .PARAMETER EnableHybridBenefitServerLicense
        Enable Azure Hybrid Benefit to use your on-premises Windows Server licenses and reduce cost.

    .PARAMETER EnableMultisessionClientLicense
        Windows10 Enterprise Multi-session

    .PARAMETER AutoInstallDependencies
        Boolean value to indicate an online or offline environment.

    .PARAMETER ArtifactsLocationSasToken
        SAS Token to access the storage location containing artifacts.

    .PARAMETER AdminPasswordOrKey
        SSH Key or password for the Linux Virtual Machine, password only for Windows deployments.

    .PARAMETER TimeInSecondsBetweenJobs
        Time between New-AzResourceGroupDeployment jobs to ensure sufficient time for pid deployment to succeed.

    .PARAMETER LinuxTemplateUri
        Specifies the URI of the Linux template file.

    .PARAMETER WindowsTemplateUri
        Specifies the URI of the Windows template file.

    .PARAMETER LinuxArtifactsLocation
        Specifies the URI of the Linux artifacts location.

    .PARAMETER WindowsArtifactsLocation
        Specifies the URI of the Windows artifacts location.

    .PARAMETER DataFilePath
        ATO Scale deployment data file (.psd1)

    .EXAMPLE
        $artifactLocationParams = .\publish-to-blob.ps1 -ResourceGroupName deploymentRG -StorageAccountName deploymentSA -ContainerName artifacts -MetadataPassthru
        $dataFilePath = 'C:\data\vmDeploymentData.psd1
        $securePassword = Read-Host -Prompt 'adminUserName password' -AsSecureString
        .\scale-deployment.ps1 @artifactLocationParams -DataFilePath $dataFilePath -AdminPasswordOrKey $securePassword

        This example uses the publish-to-blob.ps1 script to copy deployment artifact files to a storage account, then deploy the solution based on data
        from the data file.
#>

[CmdletBinding(DefaultParameterSetName = 'Default')]
Param
(
    [Parameter(Mandatory = $true, ParameterSetName = 'Default')]
    [ValidateScript({$_ -notmatch '[^\w-]'})]
    [string]
    $VmName,

    [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
    [ValidateScript({$_ -notmatch '[^\w-]'})]
    [string]
    $VmNamePrefix = $null,

    [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
    [ValidateScript({$_ -notmatch '[^\w-]'})]
    [string]
    $VmNameSuffixDelimiter = '-',

    [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
    [int]
    $VmNameSuffixStartingNumber = 1,

    [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
    [int]
    $Count,

    [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
    [string]
    $VmSize,

    [Parameter(Mandatory = $true, ParameterSetName = 'Default')]
    [ValidateSet(
        "CentOS79",
        "CentOS78",
        "CentOS77",
        "CentOS76",
        "CentOS75",
        "CentOS74",
        "RHEL84",
        "RHEL83",
        "RHEL82",
        "RHEL81GEN2",
        "RHEL81",
        "RHEL80",
        "RHEL79",
        "RHEL78",
        "RHEL77",
        "RHEL75",
        "RHEL74",
        "RHEL73",
        "RHEL72",
        "Ubuntu1804",
        "Ubuntu1804-DataScience",
        "2019-Datacenter",
        "2016-Datacenter",
        "19h2-ent",
        IgnoreCase = $false
    )]
    [string]
    $OsVersion,

    [Parameter(Mandatory = $true, ParameterSetName = 'Default')]
    [string]
    $ResourceGroupName,

    [Parameter(Mandatory = $true, ParameterSetName = 'Default')]
    [ValidateScript({[uri]::IsWellFormedUriString($_, 1)})]
    [string]
    $TemplateUri,

    [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
    [string]
    $Location,

    [Parameter(Mandatory = $true, ParameterSetName = 'Default')]
    [string]
    $AdminUserName,

    [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
    [ValidateSet(
        "new",
        "existing",
        IgnoreCase = $false
    )]
    [string]
    $VirtualNetworkNewOrExisting,

    [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
    [string]
    $VmVirtualNetwork,

    [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
    [string]
    $VirtualNetworkResourceGroupName,

    [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
    [string]
    $AddressPrefix,

    [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
    [string]
    $SubnetPrefix,

    [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
    [string]
    $SubnetName,

    [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
    [string]
    $AuthenticationType,

    [Parameter(Mandatory = $true, ParameterSetName = 'Default')]
    [ValidateScript({[uri]::IsWellFormedUriString($_, 1)})]
    [string]
    $ArtifactsLocation,

    [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
    [string]
    $DiagnosticStorageResourceId,

    [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
    [string]
    $LogAnalyticsWorkspaceId,

    [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
    [string]
    $OsDiskEncryptionSetResourceId,

    [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
    [string]
    $ApplicationSecurityGroupResourceId,

    [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
    [ValidateSet(
        "Premium_LRS",
        "Standard_LRS",
        "StandardSSD_LRS",
        IgnoreCase = $false
    )]
    [string]
    $OsDiskStorageType,

    [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
    [string]
    $CustomData,

    [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
    [string]
    $AvailabilityOptions,

    [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
    [string]
    $AvailabilitySetNameSuffix,

    [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
    [ValidateRange(1, 5)]
    [int]
    $InstanceCount,

    [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
    [ValidateRange(1, 3)]
    [int]
    $FaultDomains,

    [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
    [ValidateRange(1, 5)]
    [int]
    $UpdateDomains,

    [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
    [ValidateRange(0, 365)]
    [int]
    $LogsRetentionInDays,

    [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
    [switch]
    $EnableHybridBenefitServerLicense,

    [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
    [switch]
    $EnableMultisessionClientLicense,

    [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
    [switch]
    $AutoInstallDependencies,

    [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
    [Parameter(Mandatory = $false, ParameterSetName = 'DataFilePath')]
    [SecureString]
    $ArtifactsLocationSasToken,

    [Parameter(Mandatory = $true, ParameterSetName = 'Default')]
    [Parameter(Mandatory = $true, ParameterSetName = 'DataFilePath')]
    [SecureString]
    $AdminPasswordOrKey,

    [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
    [Parameter(Mandatory = $false, ParameterSetName = 'DataFilePath')]
    [ValidateRange(10, 120)]
    [int]
    $TimeInSecondsBetweenJobs = 10,

    [Parameter(Mandatory = $false, ParameterSetName = 'DataFilePath')]
    [ValidateScript({[uri]::IsWellFormedUriString($_, 1)})]
    [string]
    $LinuxTemplateUri,

    [Parameter(Mandatory = $false, ParameterSetName = 'DataFilePath')]
    [ValidateScript({[uri]::IsWellFormedUriString($_, 1)})]
    [string]
    $WindowsTemplateUri,

    [Parameter(Mandatory = $false, ParameterSetName = 'DataFilePath')]
    [ValidateScript({[uri]::IsWellFormedUriString($_, 1)})]
    [string]
    $LinuxArtifactsLocation,

    [Parameter(Mandatory = $false, ParameterSetName = 'DataFilePath')]
    [ValidateScript({[uri]::IsWellFormedUriString($_, 1)})]
    [string]
    $WindowsArtifactsLocation,

    [Parameter(Mandatory = $false, ParameterSetName = 'DataFilePath')]
    [ValidateScript({Test-Path -Path $_})]
    [string]
    $DataFilePath
)

if ($PSCmdlet.ParameterSetName -eq 'Default')
{
    # removing non-template params from $PSBoundParams, in order to splat New-AzResourceGroupDeployment
    $newAzResourceGroupDeploymentParams = $PSBoundParameters
    [void] $newAzResourceGroupDeploymentParams.Remove('VmName')
    [void] $newAzResourceGroupDeploymentParams.Remove('VmNamePrefix')
    [void] $newAzResourceGroupDeploymentParams.Remove('VmNameSuffixDelimiter')
    [void] $newAzResourceGroupDeploymentParams.Remove('VmNameSuffixStartingNumber')
    [void] $newAzResourceGroupDeploymentParams.Remove('Count')
    [void] $newAzResourceGroupDeploymentParams.Remove('TimeInSecondsBetweenJobs')
    [array] $psBoundKeys = $PSBoundParameters.Keys

    # adding AsJob for parallel execution
    $newAzResourceGroupDeploymentParams['AsJob'] = $true

    # updating params from friendly user defined, to template params; under-score usage
    switch ($psBoundKeys)
    {
        'ArtifactsLocation'
        {
            $newAzResourceGroupDeploymentParams['_artifactsLocation'] = $ArtifactsLocation
            [void] $newAzResourceGroupDeploymentParams.Remove('ArtifactsLocation')
        }
        'ArtifactsLocationSasToken'
        {
            $newAzResourceGroupDeploymentParams['_artifactsLocationSasToken'] = $ArtifactsLocationSasToken
            # the QueryString param is used in conjunction with TemplateUri when decrypted SAS token is used
            $decryptedSasToken = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ArtifactsLocationSasToken)
            )
            $newAzResourceGroupDeploymentParams['QueryString'] = $decryptedSasToken
            [void] $newAzResourceGroupDeploymentParams.Remove('ArtifactsLocationSasToken')
        }
    }

    # creating VM names based on user input
    $vmNames = [System.Collections.Specialized.OrderedDictionary]::new()
    for ($i = $VmNameSuffixStartingNumber; $i -le $Count; $i++)
    {
        $assembledVmName = '{0}{1}{2}{3}' -f $VmNamePrefix, $VmName, $VmNameSuffixDelimiter, $i
        if ($AvailabilityOptions -eq 'availabilitySet')
        {
            $assembledAvName = '{0}{1}{2}{3}{4}' -f $VmNamePrefix, $VmName, $VmNameSuffixDelimiter, $i, $AvailabilitySetNameSuffix
        }
        else
        {
            $assembledAvName = $null
        }

        $vmNames[$assembledVmName] = $assembledAvName
    }

    # assembled VmName validation, if invalid, we're going to fail
    if ($($vmNames.Keys)[-1].Length -gt 64 -and $OsVersion -notmatch '^\d+h\d+-e(nt|vd)$|^\d+-Datacenter$')
    {
        throw "Linux VM Name: $($($vmNames.Keys)[-1]) exceeds 64 characters, unable to continue."
    }

    if ($($vmNames.Keys)[-1].Length -gt 15 -and $OsVersion -match '^\d+h\d+-e(nt|vd)$|^\d+-Datacenter$')
    {
        throw "Windows VM Name: $($($vmNames.Keys)[-1]) exceeds 15 characters, unable to continue."
    }

    foreach ($vmName in $vmNames.Keys)
    {
        $newAzResourceGroupDeploymentParams['Name'] = $vmName
        $newAzResourceGroupDeploymentParams['VmName'] = $vmName
        if ($newAzResourceGroupDeploymentParams.ContainsKey('AvailabilitySetNameSuffix'))
        {
            # the hash table "value" of the vmName "key" is the AvailabilitySetName
            $newAzResourceGroupDeploymentParams['AvailabilitySetName'] = $vmNames[$vmName]
            [void] $newAzResourceGroupDeploymentParams.Remove('AvailabilitySetNameSuffix')
        }

        # handling OsVersion mainTemplate parameter deltas
        if ($OsVersion -match '^\d+h\d+-e(nt|vd)$|^\d+-Datacenter$')
        {
            $newAzResourceGroupDeploymentParams['adminPassword'] = $newAzResourceGroupDeploymentParams['AdminPasswordOrKey']
            [void] $newAzResourceGroupDeploymentParams.Remove('AdminPasswordOrKey')
            [void] $newAzResourceGroupDeploymentParams.Remove('AuthenticationType')
            [void] $newAzResourceGroupDeploymentParams.Remove('CustomData')
        }
        else
        {
            [void] $newAzResourceGroupDeploymentParams.Remove('AutoInstallDependencies')
            [void] $newAzResourceGroupDeploymentParams.Remove('EnableHybridBenefitServerLicense')
            [void] $newAzResourceGroupDeploymentParams.Remove('EnableMultisessionClientLicense')
        }

        $jobInfo = New-AzResourceGroupDeployment @newAzResourceGroupDeploymentParams
        $jobVerboseMessage = 'JobId: {0}; Name: {1}; For more details use: Get-Job -Id {0}; SecondsBetweenJobs: {2}' -f $jobInfo.Id, $jobInfo.Name, $TimeInSecondsBetweenJobs
        Write-Verbose -Message $jobVerboseMessage
        # sleep statement is required to provide sufficient time for pid deployment to succeed.
        Start-Sleep -Seconds $TimeInSecondsBetweenJobs
    }
}
else
{
    # import PowerShell data file, structure should mimic .psd1 documented here:
    Write-Verbose -Message "Importing deployment data file: $DataFilePath"
    $dataFileStructureLink = 'https://github.com/Azure/ato-toolkit/tree/master/stig/tools'
    $deploymentDataFileImport = Import-PowerShellDataFile -Path $DataFilePath
    Write-Verbose -Message "-- Total deployments to be created: $($($deploymentDataFileImport[$deploymentDataFileImport.Keys]).Count)"

    # if the hash table keys are more than one, fail, since the structure is incorrect.
    if ($deploymentDataFileImport.Keys.Count -gt 1)
    {
        throw "Deployment Data File structure syntax issue, see the following link for more details: $dataFileStructureLink"
    }

    # removing DataFilePath based params from $PSBoundParams so that the default param set is used when the scale-deployment script is invoked
    [void] $PSBoundParameters.Remove('DataFilePath')
    [void] $PSBoundParameters.Remove('LinuxTemplateUri')
    [void] $PSBoundParameters.Remove('LinuxArtifactsLocation')
    [void] $PSBoundParameters.Remove('WindowsTemplateUri')
    [void] $PSBoundParameters.Remove('WindowsArtifactsLocation')

    # looping through all deployment hash tables from data file
    $scriptPath = Join-Path -Path $PSScriptRoot -ChildPath 'scale-deployment.ps1'
    foreach ($newAzResourceGroupDeploymentParams in $deploymentDataFileImport[$deploymentDataFileImport.Keys -as [string]])
    {
        # if TemplateUri is not used in the data file, use Windows or Linux locations based on OsVersion
        if (-not $newAzResourceGroupDeploymentParams.ContainsKey('TemplateUri'))
        {
            # if the passed OsVersion is windows, use the WindowsTemplateUri param, else use linux
            if ($newAzResourceGroupDeploymentParams['OsVersion'] -match '^\d+h\d+-e(nt|vd)$|^\d+-Datacenter$')
            {
                $newAzResourceGroupDeploymentParams['TemplateUri'] = $WindowsTemplateUri
            }
            else
            {
                $newAzResourceGroupDeploymentParams['TemplateUri'] = $LinuxTemplateUri
            }
        }

        # if ArtifactsLocation is not used in the data file, use Windows or Linux locations based on OsVersion
        if (-not $newAzResourceGroupDeploymentParams.ContainsKey('ArtifactsLocation'))
        {
            # if the passed OsVersion is windows, use the WindowArtifactsLocation param, else use linux
            if ($newAzResourceGroupDeploymentParams['OsVersion'] -match '^\d+h\d+-e(nt|vd)$|^\d+-Datacenter$')
            {
                $newAzResourceGroupDeploymentParams['ArtifactsLocation'] = $WindowsArtifactsLocation
            }
            else
            {
                $newAzResourceGroupDeploymentParams['ArtifactsLocation'] = $LinuxArtifactsLocation
            }
        }

        # call the deployment script with data file hash table and params passed during script invocation.
        & $scriptPath @newAzResourceGroupDeploymentParams @PSBoundParameters
    }
}
