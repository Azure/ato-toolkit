output "id" {
  description = "ID of the Service Principal"
  value       = azuread_service_principal.sp.id
}

output "application_id" {
  description = "ID of the Application the Service Principal was created in."
  value       = azuread_application.application.application_id
}

output "password" {
  description = "Password for the Service Principal"
  value       = azuread_service_principal_password.spp.value
  sensitive   = true
}

output "password_end_date" {
  description = "The date when the AzureAD Service Principal password will expire"
  value       = azuread_service_principal_password.spp.end_date
}
