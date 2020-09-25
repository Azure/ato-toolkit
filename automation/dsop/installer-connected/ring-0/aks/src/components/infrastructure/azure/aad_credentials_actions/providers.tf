# Configure the GitHub Provider
provider "github" {
  version      = "~> 2.5.0"
  token        = var.access_token
  organization = var.org
}

# Configure the Azure Provider
provider "azurerm" {
  version             = "~> 2.0.0"
  subscription_id     = var.subscription_id
  storage_use_azuread = true
  features {}
}

