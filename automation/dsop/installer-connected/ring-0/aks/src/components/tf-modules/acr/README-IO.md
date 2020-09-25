## Providers

| Name | Alias | Version |
|------|-------|---------|
| azurerm |  |  |

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
|name | The name for this Registry | `string` | n/a | yes|
|principal_ids | A list of roles and principals (User, Group, Service Principals) to assign permissions | `list(object({ role = string, principal = string }))` | n/a | yes|
|resource_group_name | The name of the exsisitng resource group where all the resources will be created | `string` | n/a | yes|
|tags | The set of tags to be used to add to all resrouces created | `map(string)` | `{}` | no|
## Outputs

| Name | Description |
|------|-------------|
| helm\_url | URL of the helm chart repository in the created registry. This is used by the helm client to install the charts hosted by the registry. |
| id | ID of the created container registry. This is used by other environments to host internal docker images and helm charts. |
| login\_server | URL for the created registry. This is required for docker cli interations with the registry |
| name | Name of the created container registry. This is used by other environments to host internal docker images and helm charts. |
| resource\_group\_name | Resource group that contains the created registry. This is required (along with the name) to interact with the registry |

