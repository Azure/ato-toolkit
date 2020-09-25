output "id" {
  description = "ID of the Service Principal"
  value       = azuread_service_principal.sp.id
}

output "application_id" {
  description = "ID of the Application the Service Principal was created in."
  value       = azuread_application.sp_application.application_id
}

output "password" {
  description = "Password for the Service Principal"
  value       = azuread_application_password.sp_password.value
  sensitive   = true
}
