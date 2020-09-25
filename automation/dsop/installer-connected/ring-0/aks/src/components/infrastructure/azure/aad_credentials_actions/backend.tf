terraform {
  backend "azurerm" {
    key = "aad/aad_service_credentials.tfstate"
  }
}
