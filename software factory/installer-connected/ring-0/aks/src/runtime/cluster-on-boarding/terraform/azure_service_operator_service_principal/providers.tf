provider "azuread" {
  version             = "~> 0.8"
  subscription_id     = var.subscription_id
}

provider "azurerm" {
  version             = "~> 2.0.0"
  subscription_id     = var.subscription_id
  storage_use_azuread = true
  features {}
}