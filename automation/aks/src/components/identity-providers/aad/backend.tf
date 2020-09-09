terraform {
  backend "azurerm" {
    key = "aad/groups.tfstate"
  }
}
