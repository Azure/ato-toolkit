# Configure the Azure Provider
provider "azurerm" {
  version         = "~> 1.44.0"
  subscription_id = var.subscription_id
}
