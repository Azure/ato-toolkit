## Providers

| Name | Alias | Version |
|------|-------|---------|
| azuread |  |  |
| azurerm |  |  |
| random |  |  |

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
|key_vault_id | The ID of an existing KeyVault which will store the Service Principal Password | `string` | n/a | yes|
|name | A name used for this Service Principal | `string` | n/a | yes|
|tags | The set of tags to be used to add to all resources created | `map(string)` | n/a | yes|
## Outputs

| Name | Description |
|------|-------------|
| application\_id | ID of the Application the Service Principal was created in. |
| id | ID of the Service Principal |
| password | Password for the Service Principal |
| password\_end\_date | The date when the AzureAD Service Principal password will expire |

