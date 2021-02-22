param (
    [parameter(Mandatory=$true)] [string] $ResourceGroup
)

Log-Parameters -ScriptName $MyInvocation.MyCommand -ScriptArgs $MyInvocation.MyCommand.Parameters

Log-Information "Getting the list of deployments for cleanup"
$Deployments=(az group deployment list -g $ResourceGroup -o json) | ConvertFrom-Json

$Job = $Deployments | ForEach-Object -Parallel {
    Write-Output "Delete Deployment $($_.name) for group $($_.resourceGroup)"
    az deployment group delete -g $_.resourceGroup `
        -n $_.name

    # potential workaround for thread locks
    Start-Sleep -Seconds 5
} -AsJob -ThrottleLimit 20
$Job | Receive-Job -Wait

Log-Footer -ScriptName $MyInvocation.MyCommand
