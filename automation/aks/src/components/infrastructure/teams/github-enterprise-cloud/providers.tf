# Configure the GitHub Provider
provider "github" {
  token        = var.access_token
  organization = var.org
  version      = "v2.8.1"
}

provider "azuread" {
  subscription_id = var.subscription_id
  version         = "v0.10.0"
}

