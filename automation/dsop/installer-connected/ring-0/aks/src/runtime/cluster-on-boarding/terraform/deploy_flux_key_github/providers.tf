# Configure the GitHub Provider
provider "github" {
  token        = var.access_token
  organization = var.org
}
