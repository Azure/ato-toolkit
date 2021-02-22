param(
    
    [Parameter(Mandatory=$true, HelpMessage='namePrefix')]
    [string] $namePrefix,
    [Parameter(Mandatory=$false, HelpMessage='asJob')]
    [switch] $asJob
)

Get-AzResourceLock | Where-Object ResourceName -like "$namePrefix*" | Remove-AzResourceLock -Force

if ($asJob)
{
    Get-AzResourceGroup | Where-Object ResourceGroupName -like "$namePrefix*" | Remove-AzResourceGroup -Force -AsJob
}
else {
    Get-AzResourceGroup | Where-Object ResourceGroupName -like "$namePrefix*" | Remove-AzResourceGroup -Force
}