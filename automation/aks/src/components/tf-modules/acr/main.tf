data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

locals {
  name = replace(var.name, "/[^a-z0-9]/", "")
}

# The container registry
resource "azurerm_container_registry" "acr" {
  name                = local.name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  sku                 = "Premium"
  admin_enabled       = false
  tags                = var.tags
  network_rule_set {
    default_action = "Allow"
    virtual_network {
      action    = "Allow"
      subnet_id = var.worker_subnet_id
    }
  }
}

# Grant necessary IAM roles
resource "azurerm_role_assignment" "role_assignment" {
  count = length(var.principal_ids)

  scope                = azurerm_container_registry.acr.id
  role_definition_name = var.principal_ids[count.index]["role"]
  principal_id         = var.principal_ids[count.index]["principal"]
}
