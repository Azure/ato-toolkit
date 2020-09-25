locals {
  # Workspace Name used a prefix, limited to 6 alphanumeric characters
  prefix = var.prefix

  # Environment Name used as suffix
  application = "terraform-state"

  # Fully Qualified Environment Name
  name = "${local.prefix}-${local.application}"

  tags = {
    # Applicarion Name
    application = local.application
    # Workspace
    workspace = terraform.workspace
    # TF File Sources
    template = "src/components/infrastructure/azure/state-store"
    # Help identify resources created by terraform
    source = "terraform"
    # Protect this reource
    protected = true
  }
}

# Resources
resource "azurerm_resource_group" "rg" {
  name     = "${local.prefix}-c12-rg"
  location = var.location
  tags     = local.tags
}

resource "azurerm_storage_account" "terraform_state_sa" {
  name                     = format("%.24s", replace(lower(local.name), "/[^a-z0-9]/", ""))
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  tags                     = local.tags
  account_tier             = "Standard"
  account_replication_type = "GRS"
  enable_blob_encryption   = "true"
}

resource "azurerm_storage_container" "terraform_state_sac" {
  name                  = "${local.name}-sac"
  storage_account_name  = azurerm_storage_account.terraform_state_sa.name
  container_access_type = "private"
}
