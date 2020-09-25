output "id" {
  description = "ID of the created container registry. This is used by other environments to host internal docker images and helm charts."
  value       = azurerm_container_registry.acr.id
}

output "name" {
  description = "Name of the created container registry. This is used by other environments to host internal docker images and helm charts."
  value       = azurerm_container_registry.acr.name
}

output "resource_group_name" {
  description = "Resource group that contains the created registry. This is required (along with the name) to interact with the registry"
  value       = azurerm_container_registry.acr.resource_group_name
}

output "login_server" {
  description = "URL for the created registry. This is required for docker cli interations with the registry"
  value       = azurerm_container_registry.acr.login_server
}

output "helm_url" {
  description = "URL of the helm chart repository in the created registry. This is used by the helm client to install the charts hosted by the registry."
  value       = "https://${azurerm_container_registry.acr.login_server}/helm/v1/repo"
}
