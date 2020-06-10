param (
    [parameter(Mandatory=$true)] [DeploymentType] $DeploymentType,
    [parameter(Mandatory=$true)] [string] $AzCopyPath
)

Log-Parameters -ScriptName $MyInvocation.MyCommand -ScriptArgs $MyInvocation.MyCommand.Parameters

if ($DeploymentType -eq [DeploymentType]::DisconnectedStack -or $DeploymentType -eq [DeploymentType]::Disconnected)
{
    if ($IsWindows)
    {
        $AzCopyLocalPath = "~/.azcopy/"
        if (-not (Test-Path $AzCopyLocalPath))
        {
            Log-Information "Az Copy doesn't exist"
            New-Item -path $AzCopyLocalPath -ItemType "directory" | Out-Null
            Log-Information "Unzipping Az Copy"
            Expand-Archive $AzCopyPath ./ -Force -PassThru
            Log-Information "Copying Az Copy into place"
            Copy-Item ./*/azcopy.exe $AzCopyLocalPath
        }
        else
        {
            Log-Information "Skipping install of Az Copy. It already exists."
        }
    }
    elseif ($IsMacOS)
    {
        $AzCopyLocalPath = "~/.azcopy/"
        if (-not (Test-Path $AzCopyLocalPath))
        {
            throw "az copy has not yet been configured for macos"
        }
    }
    elseif ($IsLinux)
    {
        throw "az copy has not yet been configured for linux"
    }
}

Log-Footer -ScriptName $MyInvocation.MyCommand
