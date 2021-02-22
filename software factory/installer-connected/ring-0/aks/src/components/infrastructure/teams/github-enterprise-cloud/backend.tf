terraform {
  backend "azurerm" {
    key = "github-enterprise-cloud/teams.tfstate"
  }
}
