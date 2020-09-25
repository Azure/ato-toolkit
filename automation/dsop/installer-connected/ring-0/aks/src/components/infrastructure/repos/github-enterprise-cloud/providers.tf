# Configure the GitHub Provider
provider "github" {
  token        = var.access_token
  organization = var.org
  version      = "v2.8.1"
}
