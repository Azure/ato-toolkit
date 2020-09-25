terraform {
  backend "azurerm" {
    key = "github-enterprise-cloud/repos.tfstate"
  }
}
