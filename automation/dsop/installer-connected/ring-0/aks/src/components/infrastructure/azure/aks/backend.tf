terraform {
  backend "azurerm" {
    key = "azure/aks.tfstate"
  }
}
