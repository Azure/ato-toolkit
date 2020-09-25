terraform {
  backend "azurerm" {
    key = "azure/network.tfstate"
  }
}
