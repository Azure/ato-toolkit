terraform {
    backend "azurerm" {
         key = "repos/deploy-keys.tfstate"
         subscription_id = var.subscription_id
    }
}
