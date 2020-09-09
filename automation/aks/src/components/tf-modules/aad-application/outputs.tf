output "client_app_id" {
  value = azuread_application.aks-aad-client.application_id
}
output "server_app_id" {
  value = azuread_application.aks-aad-srv.application_id
}
output "server_app_secret" {
  value = random_password.aks-aad-srv.result
}
output "tenant_id" {
  value = data.azurerm_subscription.current.tenant_id
}
