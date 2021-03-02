$modulePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'Modules'

# Import the Helper Module
Import-Module -Name (Join-Path -Path $modulePath `
            -ChildPath 'WindowsDefenderDsc.ResourceHelper.psm1')

$script:localizedData = Get-LocalizedData -ResourceName 'ProcessMitigation' -ResourcePath (Split-Path -Parent $Script:MyInvocation.MyCommand.Path)
<#
    .SYNOPSIS
        Gets the current state of a process mitigation
    .PARAMETER MitigationTarget
        Name of the target mitigation process to apply mitigation settings to.
    .PARAMETER MitigationType
        Type of the mitigation process to apply mitigation settings to.
    .PARAMETER MitigationName
        Name of the mitigation process to apply mitigation settings to.
    .PARAMETER MitigationValue
        Value of the mitigation process to apply mitigation settings to.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $MitigationTarget,

        [Parameter(Mandatory = $true)]
        [string]
        $MitigationType,

        [Parameter(Mandatory = $true)]
        [string]
        $MitigationName,

        [Parameter(Mandatory = $true)]
        [string]
        $MitigationValue
    )

    $resultCurrentMitigations = Get-CurrentProcessMitigationSettings

    $returnVariable = @{

        MitigationTarget = $mitigationTarget
        MitigationType   = $mitigationType
        MitigationName   = $mitigationName
        MitigationValue  = $resultCurrentMitigations.$mitigationTarget.$mitigationType.$mitigationName
    }

    return $returnVariable
}

<#
    .SYNOPSIS
        Sets the current state of a process mitigation
    .PARAMETER MitigationTarget
        Name of the target mitigation process to apply mitigation settings to.
    .PARAMETER MitigationType
        Type of the mitigation process to apply mitigation settings to.
    .PARAMETER MitigationName
        Name of the mitigation process to apply mitigation settings to.
    .PARAMETER MitigationValue
        Value of the mitigation process to apply mitigation settings to.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $MitigationTarget,

        [Parameter(Mandatory = $true)]
        [string]
        $MitigationType,

        [Parameter(Mandatory = $true)]
        [string]
        $MitigationName,

        [Parameter(Mandatory = $true)]
        [string]
        $MitigationValue
    )

    $currentState = Get-TargetResource @PSBoundParameters
    if ($mitigationTarget -eq "System")
    {
        $currentPath = $env:TEMP + "\MitigationsCurrentSystem.xml"
    }
    else
    {
        $currentPath = $env:TEMP + "\MitigationsCurrent.xml"
    }

    [xml]$currentXml = Get-Content $currentPath

    if ($mitigationTarget -eq "System")
    {
        if ($currentXml.MitigationPolicy.SystemConfig.$MitigationType.$mitigationName -ne $mitigationValue)
        {
            $currentXml.MitigationPolicy.SystemConfig.$MitigationType.$mitigationName = $mitigationValue
            $currentXml.Save($currentPath)
            Write-Verbose -Message ($script:localizedData.policySetStatement -f $mitigationName, $mitigationValue)
            Set-ProcessMitigation -PolicyFilePath $currentPath
        }
    }
    else {
        foreach ($mitigation in $currentXml.MitigationPolicy.AppConfig)
        {
            if ($mitigation.Executable -eq $MitigationTarget)
            {
               if ($mitigation.$mitigationType.$mitigationName -ne $mitigationValue)
               {
                    $mitigation.$mitigationType.$mitigationName = $mitigationValue
                    $currentXml.Save($currentPath)
                    Write-Verbose -Message ($script:localizedData.policySetStatement -f $mitigationName, $mitigationValue)
                    Set-ProcessMitigation -PolicyFilePath $currentPath
               }
            }
        }


        if($currentXml.MitigationPolicy.AppConfig.Executable -notcontains $MitigationTarget)
        {
            # Set The Formatting
            $xmlsettings = New-Object System.Xml.XmlWriterSettings
            $xmlsettings.Indent = $true
            $xmlsettings.IndentChars = "    "

            # Set the File Name Create The Document
            $currentPathTemp = $env:TEMP + "\MitigationsCurrentTemp.xml"
            $xmlWriter = [System.XML.XmlWriter]::Create($currentPathTemp, $xmlsettings)

            # Write the XML Decleration and set the XSL
            $xmlWriter.WriteStartDocument()

            # Start the Root Element
            $xmlWriter.WriteStartElement("MitigationPolicy")

            $xmlWriter.WriteStartElement("AppConfig")
            $xmlWriter.WriteAttributeString("Executable",$mitigationTarget)

            $xmlWriter.WriteStartElement($MitigationType)
            $xmlWriter.WriteAttributeString($MitigationName,$MitigationValue)
            $xmlWriter.WriteEndElement()

            # Write end process
            $xmlWriter.WriteEndElement()

            # Write end root
            $xmlWriter.WriteEndElement()

            # End, Finalize and close the XML Document
            $xmlWriter.WriteEndDocument()
            $xmlWriter.Flush()
            $xmlWriter.Close()


            Set-ProcessMitigation -PolicyFilePath $currentPathTemp
        }
    }
}

<#
    .SYNOPSIS
        Tests the current state of a process mitigation
    .PARAMETER MitigationTarget
        Name of the target mitigation process to apply mitigation settings to.
    .PARAMETER MitigationType
        Type of the mitigation process to apply mitigation settings to.
    .PARAMETER MitigationName
        Name of the mitigation process to apply mitigation settings to.
    .PARAMETER MitigationValue
        Value of the mitigation process to apply mitigation settings to.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $MitigationTarget,

        [Parameter(Mandatory = $true)]
        [string]
        $MitigationType,

        [Parameter(Mandatory = $true)]
        [string]
        $MitigationName,

        [Parameter(Mandatory = $true)]
        [string]
        $MitigationValue
    )

    $inDesiredState = $true
    $currentPath = Get-CurrentProcessMitigationXml
    [xml] $currentStateXml = Get-Content $currentPath

    if ($mitigationTarget -eq "System")
    {
        if ($currentStateXml.MitigationPolicy.SystemConfig.$MitigationType.$mitigationName -ne $mitigationValue)
        {
            Write-Verbose -Message ($script:localizedData.policyNotInDesiredState -f $mitigationName, $mitigationValue)
            $inDesiredState = $false
        }
    }
    else
    {
        foreach ($mitigation in $currentStateXml.MitigationPolicy.AppConfig)
        {
            if ($mitigation.Executable -eq $MitigationTarget)
            {
                if ($mitigation.$mitigationType.$mitigationName -ne $mitigationValue)
                {
                    Write-Verbose -Message ($script:localizedData.policyNotInDesiredState -f $mitigationName, $mitigationValue)
                    $inDesiredState = $false
                }
            }
        }

        if ($currentStateXml.MitigationPolicy.AppConfig.Executable -notcontains $MitigationTarget)
        {
            Write-Verbose -Message ($script:localizedData.policyNotInDesiredState -f $mitigationName, $mitigationValue)
            $inDesiredState = $false
        }
    }

    return $inDesiredState
}

<#
    .SYNOPSIS
        Converts the the process mitigation converted in Convert-CurrentMitigation function
    .DESCRIPTION
        The this function uses the converted process mitigation to generate an xml that can be used via Set-ProcessMitigation -PolicyFilePath .\example.xml.
    .PARAMETER CurrentMitigationsConverted
        Converted process mitigations found via Convert-CurrentMitigation.
#>
function Get-CurrentProcessMitigationXml
{
    [CmdletBinding()]
    [OutputType([xml])]

    $resultCurrentMitigations = Get-CurrentProcessMitigationSettings

    # Set The Formatting
    $xmlsettings = New-Object System.Xml.XmlWriterSettings
    $xmlsettings.Indent = $true
    $xmlsettings.IndentChars = "    "

    if ($MitigationTarget -eq "System")
    {
        # Set the File Name Create The Document
        $currentPath = $env:TEMP + "\MitigationsCurrentSystem.xml"
        $xmlWriter = [System.XML.XmlWriter]::Create($currentPath, $xmlsettings)
    }
    else
    {
        # Set the File Name Create The Document
        $currentPath = $env:TEMP + "\MitigationsCurrent.xml"
        $xmlWriter = [System.XML.XmlWriter]::Create($currentPath, $xmlsettings)
    }

    # Write the XML Decleration and set the XSL
    $xmlWriter.WriteStartDocument()

    # Start the Root Element
    $xmlWriter.WriteStartElement("MitigationPolicy")

    foreach($mitigation in $resultCurrentMitigations)
    {
        if ($MitigationTarget -eq "System")
        {
            # Write process name
            $xmlWriter.WriteStartElement("SystemConfig")
        }
        else
        {
            # Write process name
            $xmlWriter.WriteStartElement("AppConfig")
            $xmlWriter.WriteAttributeString("Executable",$mitigation.Keys)
        }

        # Write DEP Settings
        $xmlWriter.WriteStartElement("DEP")
        $xmlWriter.WriteAttributeString("Enable",$mitigation.Values.dep.Enable)
        $xmlWriter.WriteAttributeString("EmulateAtlThunks",$mitigation.Values.dep.EmulateAtlThunks)
        $xmlWriter.WriteAttributeString("OverrideDEP",$mitigation.Values.dep.OverrideDEP)
        $xmlWriter.WriteEndElement()

        # Write ASLR Settings
        $xmlWriter.WriteStartElement("ASLR")
        $xmlWriter.WriteAttributeString("HighEntropy",$mitigation.Values.aslr.HighEntropy)
        $xmlWriter.WriteAttributeString("OverrideHighEntropy",$mitigation.Values.aslr.OverrideHighEntropy)
        $xmlWriter.WriteAttributeString("BottomUp",$mitigation.Values.aslr.BottomUp)
        $xmlWriter.WriteAttributeString("OverrideForceRelocateImages",$mitigation.Values.aslr.OverrideForceRelocateImages)
        $xmlWriter.WriteAttributeString("RequireInfo",$mitigation.Values.aslr.RequireInfo)
        $xmlWriter.WriteAttributeString("ForceRelocateImages",$mitigation.Values.aslr.ForceRelocateImages)
        $xmlWriter.WriteAttributeString("OverrideBottomUp",$mitigation.Values.aslr.OverrideBottomUp)
        $xmlWriter.WriteEndElement()

        # Write StrictHandle Settings
        $xmlWriter.WriteStartElement("StrictHandle")
        $xmlWriter.WriteAttributeString("Enable",$mitigation.Values.StrictHandle.Enable)
        $xmlWriter.WriteAttributeString("OverrideStrictHandle",$mitigation.Values.StrictHandle.OverrideStrictHandle)
        $xmlWriter.WriteEndElement()

        # Write SystemCalls Settings
        $xmlWriter.WriteStartElement("SystemCalls")
        $xmlWriter.WriteAttributeString("DisableWin32kSystemCalls",$mitigation.Values.SystemCalls.DisableWin32kSystemCalls)
        $xmlWriter.WriteAttributeString("Audit",$mitigation.Values.SystemCalls.Audit)
        $xmlWriter.WriteAttributeString("OverrideSystemCall",$mitigation.Values.SystemCalls.OverrideSystemCall)
        $xmlWriter.WriteEndElement()

        # Write ExtensionPoints Settings
        $xmlWriter.WriteStartElement("ExtensionPoints")
        $xmlWriter.WriteAttributeString("DisableExtensionPoints",$mitigation.Values.ExtensionPoints.DisableExtensionPoints)
        $xmlWriter.WriteAttributeString("OverrideExtensionPoint",$mitigation.Values.ExtensionPoints.OverrideExtensionPoint)
        $xmlWriter.WriteEndElement()

        # Write DynamicCode Settings
        $xmlWriter.WriteStartElement("DynamicCode")
        $xmlWriter.WriteAttributeString("OverrideDynamicCode",$mitigation.Values.DynamicCode.OverrideDynamicCode)
        $xmlWriter.WriteAttributeString("BlockDynamicCode",$mitigation.Values.DynamicCode.BlockDynamicCode)
        $xmlWriter.WriteAttributeString("Audit",$mitigation.Values.DynamicCode.Audit)
        $xmlWriter.WriteAttributeString("AllowThreadsToOptOut",$mitigation.Values.DynamicCode.AllowThreadsToOptOut)
        $xmlWriter.WriteEndElement()

        # Write ControlFlowGuard Settings
        $xmlWriter.WriteStartElement("ControlFlowGuard")
        $xmlWriter.WriteAttributeString("StrictControlFlowGuard",$mitigation.Values.ControlFlowGuard.StrictControlFlowGuard)
        $xmlWriter.WriteAttributeString("OverrideCFG",$mitigation.Values.ControlFlowGuard.OverrideCFG)
        $xmlWriter.WriteAttributeString("OverrideStrictCFG",$mitigation.Values.ControlFlowGuard.OverrideStrictCFG)
        $xmlWriter.WriteAttributeString("Enable",$mitigation.Values.ControlFlowGuard.Enable)
        $xmlWriter.WriteAttributeString("SuppressExports",$mitigation.Values.ControlFlowGuard.SuppressExports)
        $xmlWriter.WriteEndElement()

        # Write SignedBinaries Settings
        $xmlWriter.WriteStartElement("SignedBinaries")
        $xmlWriter.WriteAttributeString("AllowStoreSignedBinaries",$mitigation.Values.SignedBinaries.AllowStoreSignedBinaries)
        $xmlWriter.WriteAttributeString("AuditMicrosoftSignedOnly",$mitigation.Values.SignedBinaries.AuditMicrosoftSignedOnly)
        $xmlWriter.WriteAttributeString("OverrideMicrosoftSignedOnly",$mitigation.Values.SignedBinaries.OverrideMicrosoftSignedOnly)
        $xmlWriter.WriteAttributeString("AuditEnforceModuleDependencySigning",$mitigation.Values.SignedBinaries.AuditEnforceModuleDependencySigning)
        $xmlWriter.WriteAttributeString("AuditStoreSigned",$mitigation.Values.SignedBinaries.AuditStoreSigned)
        $xmlWriter.WriteAttributeString("OverrideDependencySigning",$mitigation.Values.SignedBinaries.OverrideDependencySigning)
        $xmlWriter.WriteAttributeString("MicrosoftSignedOnly",$mitigation.Values.SignedBinaries.MicrosoftSignedOnly)
        $xmlWriter.WriteAttributeString("EnforceModuleDependencySigning",$mitigation.Values.SignedBinaries.EnforceModuleDependencySigning)
        $xmlWriter.WriteEndElement()

        # Write Fonts Settings
        $xmlWriter.WriteStartElement("Fonts")
        $xmlWriter.WriteAttributeString("OverrideFontDisable",$mitigation.Values.Fonts.OverrideFontDisable)
        $xmlWriter.WriteAttributeString("Audit",$mitigation.Values.Fonts.Audit)
        $xmlWriter.WriteAttributeString("DisableNonSystemFonts",$mitigation.Values.Fonts.DisableNonSystemFonts)
        $xmlWriter.WriteEndElement()

        # Write ImageLoad Settings
        $xmlWriter.WriteStartElement("ImageLoad")
        $xmlWriter.WriteAttributeString("OverrideBlockLowLabel",$mitigation.Values.ImageLoad.OverrideBlockLowLabel)
        $xmlWriter.WriteAttributeString("OverridePreferSystem32",$mitigation.Values.ImageLoad.OverridePreferSystem32)
        $xmlWriter.WriteAttributeString("OverrideBlockRemoteImageLoads",$mitigation.Values.ImageLoad.OverrideBlockRemoteImageLoads)
        $xmlWriter.WriteAttributeString("AuditPreferSystem32",$mitigation.Values.ImageLoad.AuditPreferSystem32)
        $xmlWriter.WriteAttributeString("PreferSystem32",$mitigation.Values.ImageLoad.PreferSystem32)
        $xmlWriter.WriteAttributeString("AuditLowLabelImageLoads",$mitigation.Values.ImageLoad.AuditLowLabelImageLoads)
        $xmlWriter.WriteAttributeString("BlockLowLabelImageLoads",$mitigation.Values.ImageLoad.BlockLowLabelImageLoads)
        $xmlWriter.WriteAttributeString("AuditRemoteImageLoads",$mitigation.Values.ImageLoad.AuditRemoteImageLoads)
        $xmlWriter.WriteAttributeString("BlockRemoteImageLoads",$mitigation.Values.ImageLoad.BlockRemoteImageLoads)
        $xmlWriter.WriteEndElement()

        # Write Payload Settings
        $xmlWriter.WriteStartElement("Payload")
        $xmlWriter.WriteAttributeString("EAFModules","")
        $xmlWriter.WriteAttributeString("AuditEnableExportAddressFilterPlus",$mitigation.Values.Payload.AuditEnableExportAddressFilterPlus)
        $xmlWriter.WriteAttributeString("EnableRopStackPivot",$mitigation.Values.Payload.EnableRopStackPivot)
        $xmlWriter.WriteAttributeString("EnableExportAddressFilter",$mitigation.Values.Payload.EnableExportAddressFilter)
        $xmlWriter.WriteAttributeString("OverrideEnableRopStackPivot",$mitigation.Values.Payload.OverrideEnableRopStackPivot)
        $xmlWriter.WriteAttributeString("AuditEnableRopCallerCheck",$mitigation.Values.Payload.AuditEnableRopCallerCheck)
        $xmlWriter.WriteAttributeString("OverrideEnableRopCallerCheck",$mitigation.Values.Payload.OverrideEnableRopCallerCheck)
        $xmlWriter.WriteAttributeString("AuditEnableRopStackPivot",$mitigation.Values.Payload.AuditEnableRopStackPivot)
        $xmlWriter.WriteAttributeString("OverrideEnableImportAddressFilter",$mitigation.Values.Payload.OverrideEnableImportAddressFilter)
        $xmlWriter.WriteAttributeString("OverrideEnableExportAddressFilter",$mitigation.Values.Payload.OverrideEnableExportAddressFilter)
        $xmlWriter.WriteAttributeString("EnableExportAddressFilterPlus",$mitigation.Values.Payload.EnableExportAddressFilterPlus)
        $xmlWriter.WriteAttributeString("AuditEnableRopSimExec",$mitigation.Values.Payload.AuditEnableRopSimExec)
        $xmlWriter.WriteAttributeString("AuditEnableImportAddressFilter",$mitigation.Values.Payload.AuditEnableImportAddressFilter)
        $xmlWriter.WriteAttributeString("OverrideEnableRopSimExec",$mitigation.Values.Payload.OverrideEnableRopSimExec)
        $xmlWriter.WriteAttributeString("EnableRopCallerCheck",$mitigation.Values.Payload.EnableRopCallerCheck)
        $xmlWriter.WriteAttributeString("AuditEnableExportAddressFilter",$mitigation.Values.Payload.AuditEnableExportAddressFilter)
        $xmlWriter.WriteAttributeString("EnableRopSimExec",$mitigation.Values.Payload.EnableRopSimExec)
        $xmlWriter.WriteAttributeString("EnableImportAddressFilter",$mitigation.Values.Payload.EnableImportAddressFilter)
        $xmlWriter.WriteAttributeString("OverrideEnableExportAddressFilterPlus",$mitigation.Values.Payload.OverrideEnableExportAddressFilterPlus)
        $xmlWriter.WriteEndElement()

        # Write SEHOP Settings
        $xmlWriter.WriteStartElement("SEHOP")
        $xmlWriter.WriteAttributeString("TelemetryOnly",$mitigation.Values.SEHOP.TelemetryOnly)
        $xmlWriter.WriteAttributeString("Enable",$mitigation.Values.SEHOP.Enable)
        $xmlWriter.WriteAttributeString("Audit",$mitigation.Values.SEHOP.Audit)
        $xmlWriter.WriteAttributeString("OverrideSEHOP",$mitigation.Values.SEHOP.OverrideSEHOP)
        $xmlWriter.WriteEndElement()

        # Write Heap Settings
        $xmlWriter.WriteStartElement("Heap")
        $xmlWriter.WriteAttributeString("TerminateOnError",$mitigation.Values.Heap.TerminateOnError)
        $xmlWriter.WriteAttributeString("OverrideHeap",$mitigation.Values.Heap.OverrideHeap)
        $xmlWriter.WriteEndElement()

        # Write ChildProcess Settings
        $xmlWriter.WriteStartElement("ChildProcess")
        $xmlWriter.WriteAttributeString("OverrideChildProcess",$mitigation.Values.ChildProcess.OverrideChildProcess)
        $xmlWriter.WriteAttributeString("DisallowChildProcessCreation",$mitigation.Values.ChildProcess.DisallowChildProcessCreation)
        $xmlWriter.WriteAttributeString("Audit",$mitigation.Values.ChildProcess.Audit)
        $xmlWriter.WriteEndElement()

        # Write end process
        $xmlWriter.WriteEndElement()
    }
    # Write end root
    $xmlWriter.WriteEndElement()


    # End, Finalize and close the XML Document
    $xmlWriter.WriteEndDocument()
    $xmlWriter.Flush()
    $xmlWriter.Close()

    return $currentPath
}

<#
    .SYNOPSIS
        Retrieves the current mitigation settings from the system
    .DESCRIPTION
        This function gets the current settings from the system and converts them into values that are required for the process mitigation xml.
#>
function Get-CurrentProcessMitigationSettings
{
    [CmdletBinding()]

    $currentMitigation = @()
    [hashtable[]]$resultCurrentMitigations = @()
    if ($mitigationTarget -eq "System")
    {
        $currentMitigation = Get-ProcessMitigation -System
    }
    else
    {
        $currentMitigation = Get-ProcessMitigation
    }

    foreach ($mitigation in $currentMitigation)
    {
        $resultCurrentMitigations +=  @{
            $mitigation.Processname = @{
                DEP = @{
                    EmulateAtlThunks = $mitigation.Dep.EmulateAtlThunks
                    OverrideDEP      = $mitigation.Dep.OverrideDEP
                    Enable           = $mitigation.Dep.Enable
                }
                ASLR = @{
                    OverrideForceRelocateImages = $mitigation.Aslr.OverrideForceRelocateImages
                    OverrideBottomUp            = $mitigation.Aslr.OverrideBottomUp
                    OverrideHighEntropy         = $mitigation.Aslr.OverrideHighEntropy
                    ForceRelocateImages         = $mitigation.Aslr.ForceRelocateImages
                    RequireInfo                 = $mitigation.Aslr.RequireInfo
                    BottomUp                    = $mitigation.Aslr.BottomUp
                    HighEntropy                 = $mitigation.Aslr.HighEntropy
                }
                StrictHandle = @{
                    Enable               = $mitigation.StrictHandle.Enable
                    OverrideStrictHandle = $mitigation.StrictHandle.OverrideStrictHandle
                }
                SystemCalls = @{
                    OverrideSystemCall       = $mitigation.SystemCall.OverrideSystemCall
                    DisableWin32kSystemCalls = $mitigation.SystemCall.DisableWin32kSystemCalls
                    Audit                    = $mitigation.SystemCall.Audit
                }
                ExtensionPoints = @{
                    DisableExtensionPoints  = $mitigation.ExtensionPoint.DisableExtensionPoints
                    OverrideExtensionPoint = $mitigation.ExtensionPoint.OverrideExtensionPoint
                }
                DynamicCode = @{
                    OverrideDynamicCode  = $mitigation.DynamicCode.OverrideDynamicCode
                    BlockDynamicCode     = $mitigation.DynamicCode.BlockDynamicCode
                    AllowThreadsToOptOut = $mitigation.DynamicCode.AllowThreadsToOptOut
                    Audit                = $mitigation.DynamicCode.Audit
                }
                ControlFlowGuard = @{
                    OverrideCFG            = $mitigation.CFG.OverrideCFG
                    OverrideStrictCFG      = $mitigation.CFG.OverrideStrictCFG
                    Enable                 = $mitigation.CFG.Enable
                    SuppressExports        = $mitigation.CFG.SuppressExports
                    StrictControlFlowGuard = $mitigation.CFG.StrictControlFlowGuard
                }
                SignedBinaries = @{
                    MicrosoftSignedOnly                    = $mitigation.BinarySignature.MicrosoftSignedOnly
                    AllowStoreSignedBinaries               = $mitigation.BinarySignature.AllowStoreSignedBinaries
                    EnforceModuleDependencySigning         = $mitigation.BinarySignature.EnforceModuleDependencySigning
                    AuditMicrosoftSignedOnly               = $mitigation.BinarySignature.Audit
                    AuditStoreSigned                       = $mitigation.BinarySignature.AuditStoreSigned
                    AuditEnforceModuleDependencySigning    = $mitigation.BinarySignature.AuditEnforceModuleDependencySigning
                    OverrideMicrosoftSignedOnly            = $mitigation.BinarySignature.OverrideMicrosoftSignedOnly
                    OverrideEnforceModuleDependencySigning = $mitigation.BinarySignature.OverrideEnforceModuleDependencySigning
                }
                Fonts = @{
                    DisableNonSystemFonts = $mitigation.FontDisable.DisableNonSystemFonts
                    Audit                 = $mitigation.FontDisable.Audit
                    OverrideFontDisable   = $mitigation.FontDisable.OverrideFontDisable
                }
                ImageLoad = @{
                    AuditLowLabelImageLoads       = $mitigation.ImageLoad.AuditLowLabelImageLoads
                    AuditPreferSystem32           = $mitigation.ImageLoad.AuditPreferSystem32
                    AuditRemoteImageLoads         = $mitigation.ImageLoad.AuditRemoteImageLoads
                    BlockLowLabelImageLoads       = $mitigation.ImageLoad.BlockLowLabelImageLoads
                    BlockRemoteImageLoads         = $mitigation.ImageLoad.BlockRemoteImageLoads
                    OverrideBlockLowLabel         = $mitigation.ImageLoad.OverrideBlockLowLabel
                    OverrideBlockRemoteImageLoads = $mitigation.ImageLoad.OverrideBlockRemoteImageLoads
                    OverridePreferSystem32        = $mitigation.ImageLoad.OverridePreferSystem32
                    PreferSystem32                = $mitigation.ImageLoad.PreferSystem32
                }
                PayLoad = @{
                    AuditEnableExportAddressFilter        = $mitigation.Payload.AuditEnableExportAddressFilter
                    AuditEnableExportAddressFilterPlus    = $mitigation.Payload.AuditEnableExportAddressFilterPlus
                    AuditEnableImportAddressFilter        = $mitigation.Payload.AuditEnableImportAddressFilter
                    AuditEnableRopCallerCheck             = $mitigation.Payload.AuditEnableRopCallerCheck
                    AuditEnableRopSimExec                 = $mitigation.Payload.AuditEnableRopSimExec
                    AuditEnableRopStackPivot              = $mitigation.Payload.AuditEnableRopStackPivot
                    EAFModules                            = $mitigation.Payload.EAFModules
                    EnableExportAddressFilter             = $mitigation.Payload.EnableExportAddressFilter
                    EnableExportAddressFilterPlus         = $mitigation.Payload.EnableExportAddressFilterPlus
                    EnableImportAddressFilter             = $mitigation.Payload.EnableImportAddressFilter
                    EnableRopCallerCheck                  = $mitigation.Payload.EnableRopCallerCheck
                    EnableRopSimExec                      = $mitigation.Payload.EnableRopSimExec
                    EnableRopStackPivot                   = $mitigation.Payload.EnableRopStackPivot
                    OverrideEnableExportAddressFilter     = $mitigation.Payload.OverrideEnableExportAddressFilter
                    OverrideEnableExportAddressFilterPlus = $mitigation.Payload.OverrideEnableExportAddressFilterPlus
                    OverrideEnableImportAddressFilter     = $mitigation.Payload.OverrideEnableImportAddressFilter
                    OverrideEnableRopCallerCheck          = $mitigation.Payload.OverrideEnableRopCallerCheck
                    OverrideEnableRopSimExec              = $mitigation.Payload.OverrideEnableRopSimExec
                    OverrideEnableRopStackPivot           = $mitigation.Payload.OverrideEnableRopStackPivot
                }
                SEHOP = @{
                    Audit         = $mitigation.SEHOP.Audit
                    Enable        = $mitigation.SEHOP.Enable
                    OverrideSEHOP = $mitigation.SEHOP.OverrideSEHOP
                    TelemetryOnly = $mitigation.SEHOP.TelemetryOnly
                }
                Heap = @{
                    OverrideHeap     = $mitigation.Heap.OverrideHeap
                    TerminateOnError = $mitigation.Heap.TerminateOnError
                }
                ChildProcess = @{
                    Audit                        = $mitigation.ChildProcess.Audit
                    DisallowChildProcessCreation = $mitigation.ChildProcess.DisallowChildProcessCreation
                    OverrideChildProcess         = $mitigation.ChildProcess.OverrideChildProcess
                }
            }
        }
    }

    $mitigationTypes = @('ControlFlowGuard','SystemCalls','StrictHandle','DynamicCode','PayLoad','ASLR','Heap','Fonts','SignedBinaries','ImageLoad','SEHOP','ExtensionPoints','DEP','ChildProcess')
    foreach ($target in  $resultCurrentMitigations.GetEnumerator())
    {
        if($target.Keys -eq "System")
        {
            $target = $resultCurrentMitigations.System
        }
        else
        {
            $targetName = $target.Keys
            $target = $resultCurrentMitigations.$targetName
        }

        foreach ($mitigationTypeName in $mitigationTypes)
        {
            [string[]] $mitigationKeys = $target.$mitigationTypeName.Keys
            foreach ($mitigationKey in $mitigationKeys)
            {
                $targetKey = $target.$mitigationTypeName.$mitigationKey
                if ($targetKey -match "ON|True")
                {
                    $target.$mitigationTypeName.$mitigationKey =  "true"
                }

                if ($targetKey -match "False|OFF")
                {
                    $target.$mitigationTypeName.$mitigationKey =  "false"
                }

                if ($targetKey -match 'NOTSET' -or $targetKey.count -lt 1)
                {
                    $target.$mitigationTypeName.Remove($mitigationkey)
                }
            }
        }
    }

    return $resultCurrentMitigations
}
