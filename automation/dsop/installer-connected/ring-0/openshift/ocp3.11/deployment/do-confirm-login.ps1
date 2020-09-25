param (
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidatePattern('(?i)\A\{?[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\}?\z')]
    [string] $TenantId,

    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidatePattern('(?i)\A\{?[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\}?\z')]
    [string] $SubscriptionId,

    [parameter(Mandatory=$true)]
    [DeploymentType] $DeploymentType
)

Log-Parameters -ScriptName $MyInvocation.MyCommand -ScriptArgs $MyInvocation.MyCommand.Parameters

$proc = "az"

if ($DeploymentType -ne [DeploymentType]::Disconnected) {

    Log-Information "Verifying az cli is logged into $TenantId"
    $TenantLogin=(az account list --query "[?tenantId=='$TenantId']" -o json) | ConvertFrom-Json
    if (-not $TenantLogin)
    {
        Log-Warning "Not logged in. Requesting now."
        $argList = "login --tenant $TenantId"
        $retVal = Run-Command -Process $proc -Arguments $argList
    }

    Log-Information "Login confirmed. Setting subscription."
    $argList = "account set -s $SubscriptionId"
    $retVal = Run-Command -Process $proc -Arguments $argList

    $argList = "account list -o table"
    $retVal = Run-Command -Process $proc -Arguments $argList
}
else
{
    Log-Information "Not confirming login. We currently do not confirm login for a disconnected deployment."
}

Log-Footer -ScriptName $MyInvocation.MyCommand
