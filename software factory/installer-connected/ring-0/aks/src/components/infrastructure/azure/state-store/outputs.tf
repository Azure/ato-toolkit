# Outputs

output "storage_account_name" {
  description = "The name of the Storage Account used for Terraform State"
  value       = azurerm_storage_account.terraform_state_sa.name
}

output "container_name" {
  description = "The container name used for Terraform State"
  value       = azurerm_storage_container.terraform_state_sac.name
}

output "access_key" {
  description = "The access key of the Storage Account used for Terraform State"
  value       = azurerm_storage_account.terraform_state_sa.primary_access_key
}

output "arm_rg_name" {
  value = azurerm_resource_group.rg.name
}
