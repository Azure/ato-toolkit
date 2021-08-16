data "azurerm_subscription" "current" {
}

locals {
  cluster_name  = var.cluster_name
  name          = "${var.cluster_name}-aso"
}

# rbac sp
resource "azuread_application" "sp_application" {
  name                       = "${local.name}-sp"
  available_to_other_tenants = false

}

resource "random_password" "sp_password" {
  length   = 32
  special  = true
}

resource "azuread_service_principal" "sp" {
  application_id = azuread_application.sp_application.application_id
}

# Create role assignment for service principal
resource "azurerm_role_assignment" "contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.sp.id
}

resource "azuread_application_password" "sp_password" {
  application_object_id = azuread_application.sp_application.object_id
  value                 = random_password.sp_password.result
  end_date_relative     = "17520h" #expire in 2 years
}
