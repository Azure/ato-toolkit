## Providers

| Name | Alias | Version |
|------|-------|---------|
| azurerm |  |  |

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
|aks_service_principal_id | The ID of the Service Principal that will be assigned with `ACRPull` permissions | `string` | n/a | yes|
|name | The name for this Registry | `string` | n/a | yes|
|resource_group_name | The name of the exsisitng resource group where all the resources will be created | `string` | n/a | yes|
## Outputs

| Name | Description |
|------|-------------|
| registry\_login\_server | URL for the created registry. This is required for docker cli interations with the registry |
| role\_assignment\_id | The ID of the role assignment that allows the provided Service Principal to pull images and charts from the registry |

