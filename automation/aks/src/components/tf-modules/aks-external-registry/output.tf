
output "role_assignment_id" {
  description = "The ID of the role assignment that allows the provided Service Principal to pull images and charts from the registry"
  value       = azurerm_role_assignment.acr_spn_pull_role_assn.id
}
