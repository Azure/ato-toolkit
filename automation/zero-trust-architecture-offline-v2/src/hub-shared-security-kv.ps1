
param(
    [string]
    [Parameter(Mandatory = $true)] $namePrefix,
    [string]
    [Parameter(Mandatory = $true)] $hubName,
    [string]
    [Parameter(Mandatory = $true)] $location
)
        
$ErrorActionPreference = 'Stop'
$DeploymentScriptOutputs = @{}

$DeployPrefix = $namePrefix + '-' + $hubName
$ResourceGroupName = $DeployPrefix + '-rg'
$VaultName = $DeployPrefix + '-kv'
$LocationName = $location

$KeyName = $DeployPrefix + '-disk-encryption-key'
$StorageAcctKeyName = $DeployPrefix + '-sa-diag-encryption-key'
$DiskEncryptionSetName = $DeployPrefix + '-disk-encryption-set'
$kekEncryptionUrlSecretName = 'disk-key-kek-kid'

# Get KeyVault
$kv = Get-AzKeyVault -Name $VaultName -ResourceGroupName $ResourceGroupName
              
# Check if Disk Encryption Key exists
$diskEncrptKey = `
(Get-AzKeyVaultKey `
        -VaultName $VaultName `
        -Name $KeyName `
        -ErrorAction SilentlyContinue).Id;
           
# Create New Disk Encryption Key
if ($null -eq $diskEncrptKey) {
    $diskEncrptKey = (Add-AzKeyVaultKey `
            -VaultName $VaultName `
            -Name $KeyName `
            -Destination 'HSM').Id;
}

# Check if Storage Account Encryption Key exists
$storAcctKey = `
(Get-AzKeyVaultKey `
        -VaultName $VaultName `
        -Name $StorageAcctKeyName `
        -ErrorAction SilentlyContinue).Id;

# Create New Storage Account Encryption Key
if ($null -eq $storAcctKey) {
    $storAcctKey = (Add-AzKeyVaultKey `
            -VaultName $VaultName `
            -Name $StorageAcctKeyName `
            -Destination 'Software').Id;
}
                
# Get Disk Encryption Newly Created Key
$diskEncrptKey = (Get-AzKeyVaultKey `
        -VaultName $VaultName `
        -Name $KeyName)

# Update secret for KeK encryption with KV KeK URL
$secretvalue = ConvertTo-SecureString $diskEncrptKey.Key.Kid -AsPlainText -Force
$secret = Set-AzKeyVaultSecret -VaultName $VaultName -Name $kekEncryptionUrlSecretName -SecretValue $secretvalue

# Create New Disk Encryption Set Config
$desConfig = (New-AzDiskEncryptionSetConfig `
        -Location $LocationName `
        -SourceVaultId $kv.ResourceId `
        -KeyUrl $diskEncrptKey.Key.Kid `
        -IdentityType SystemAssigned)
                    
# Create New Disk Encryption Set
$desEncrySet = (New-AzDiskEncryptionSet `
        -Name $DiskEncryptionSetName `
        -ResourceGroupName $ResourceGroupName `
        -InputObject $desConfig)

# Get newly created disk encryption Set
$des = (Get-AzDiskEncryptionSet `
        -ResourceGroupName $ResourceGroupName `
        -Name $DiskEncryptionSetName)
                      
# Add the Disk Encryption Set Application to Key Vault Access Policy
(Set-AzKeyVaultAccessPolicy `
        -VaultName $VaultName `
        -ObjectId $des.Identity.PrincipalId `
        -PermissionsToKeys wrapkey, unwrapkey, get `
        -BypassObjectIdValidation)

# Encrypt Storage Account that is deployed in ZTA
# Set Managed identity in storage account:
foreach ($StorageAcctName in Get-AzStorageAccount -ResourceGroupName $ResourceGroupName | Select-Object StorageAccountName) {
        Write-Host $StorageAcctName.StorageAccountName

        $storageAccount = (Set-AzStorageAccount `
                -ResourceGroupName $ResourceGroupName `
                -Name $StorageAcctName.StorageAccountName `
                -AssignIdentity)
                
        # Add Storage Account identity to KeyVault Access Policy
        (Set-AzKeyVaultAccessPolicy `
                -VaultName $kv.VaultName `
                -ObjectId $storageAccount.Identity.PrincipalId `
                -PermissionsToKeys wrapkey, unwrapkey, get `
                -BypassObjectIdValidation)
                
        # Get Storage Account Encryption Newly Created Key
        $storAcctKey = (Get-AzKeyVaultKey `
                -VaultName $VaultName `
                -Name $StorageAcctKeyName)

        # Encrypt the storage account with Key Vault Key
        (Set-AzStorageAccount -ResourceGroupName $ResourceGroupName `
                -AccountName $StorageAcctName.StorageAccountName `
                -KeyvaultEncryption `
                -KeyName $storAcctKey.Name `
                -KeyVersion $storAcctKey.Version `
                -KeyVaultUri $kv.VaultUri)
}

# Now that all KV actions are done, remove the network access
Update-AzKeyVaultNetworkRuleSet -VaultName $VaultName -DefaultAction Deny