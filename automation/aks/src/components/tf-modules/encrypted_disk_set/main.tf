# Resources
data "azurerm_resource_group" "rg" {
  name = "${local.prefix}-c12-rg"
}

data "azurerm_client_config" "current" {}

locals {
  # Workspace Name used a prefix, limited to 6 alphanumeric characters
  prefix = var.prefix

  location = data.azurerm_resource_group.rg.location
  rg_name = data.azurerm_resource_group.rg.name
  # Environment Name used as suffix
  application = "aks"

  # Fully Qualified Environment Name
  name = "${local.prefix}-aks"

  # The random part is required to allow environment recreation as once a kv with purge_protection_enabled = true is created,
  # then the name can't be used and it can be purged after deleted (and purge_protection_enabled    = true is mandatory for encrypted disk)
  # 2byte max length in decimal characters is 5 (65535) + 4 in dashes and 'kv' keyword
  kv_name = "${substr(local.name,0,14)}-${random_id.dedup.dec}-kv"

  tags = {
    # Applicarion Name
    application = local.application
    # Workspace
    workspace = terraform.workspace
    # TF File Sources
    template = "src/components/infrastructure/azure/encrypted_disk_set"
    # Help identify resources created by terraform
    source = "terraform"
    # Protect this reource
    protected = true
  }
}

resource "random_id" "dedup" {
  byte_length = 2
}


resource "azurerm_key_vault" "kv" {
  name                        = local.kv_name
  location                    = local.location
  resource_group_name         = local.rg_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "premium"
  enabled_for_disk_encryption = true
  soft_delete_enabled         = true
  purge_protection_enabled    = true

  tags = local.tags
}

resource "azurerm_key_vault_key" "disk-key" {
  name         = "disk-encryption-key"
  key_vault_id = azurerm_key_vault.kv.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  tags = local.tags

  depends_on = [
    azurerm_key_vault_access_policy.sp-encryption-perm
  ]
}

resource "azurerm_disk_encryption_set" "aks-disk-encryption-set" {
  name                = "${local.name}-des"
  resource_group_name = local.rg_name
  location            = local.location
  key_vault_key_id    = azurerm_key_vault_key.disk-key.id

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}

resource "azurerm_key_vault_access_policy" "disk-encryption-perm" {
  key_vault_id = azurerm_key_vault.kv.id

  tenant_id = azurerm_disk_encryption_set.aks-disk-encryption-set.identity.0.tenant_id
  object_id = azurerm_disk_encryption_set.aks-disk-encryption-set.identity.0.principal_id

  key_permissions = [
    "get",
    "wrapkey",
    "unwrapkey",
  ]
}

resource "azurerm_key_vault_access_policy" "sp-encryption-perm" {
  key_vault_id = azurerm_key_vault.kv.id

  tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
	  "get",
	  "create",
	  "delete",
    "purge"
    ]
}