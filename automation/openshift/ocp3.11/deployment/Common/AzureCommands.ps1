$Global:AzureCommands = @{}
$Global:AzureCommands.AzureProcessName = "az"


<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER ResourceGroup
Parameter description

.PARAMETER VmName
Parameter description

.PARAMETER JsonFile
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>

function New-AzureLinuxExtension
{
    param (
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ResourceGroup,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$VmName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$JsonFile
    )

    # Get existing installed extension(s)
    $existingExtension = az vm extension list -g $ResourceGroup --vm-name $VmName -o json | ConvertFrom-Json

    # Delete if necessary.  in our case there should only be one.
    if ($existingExtension.Count -gt 0)
    {
        $argList = "vm extension delete " +
                    "-g $ResourceGroup " +
                    "--vm-name $VmName " +
                    "--name $($existingExtension.Name)"

        Run-Command -Process $Global:AzureCommands.AzureProcessName -Arguments $argList
    }

    # install new extension, running base64 encoded script from above
    $argList = "vm extension set " +
                "-g $ResourceGroup " +
                "--vm-name $VmName " +
                "--extension-instance-name prep " +
                "--name customScript " +
                "--publisher Microsoft.Azure.Extensions " +
                "--settings $JsonFile"

    Run-Command -Process $Global:AzureCommands.AzureProcessName -Arguments $argList

}

function Get-AzureLinuxExtensionMessageOutput
{
    param (
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ResourceGroup,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$VmName
    )

    $argList = "vm get-instance-view " +
            "--resource-group $ResourceGroup " +
            "--name $VmName " +
            "--query instanceView.extensions[0].statuses[0].message " +
            "-o tsv"
    
    Run-Command -Process $Global:AzureCommands.AzureProcessName -Arguments $argList
}