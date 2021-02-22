locals {
  # Workspace Name used a prefix, limited to 6 alphanumeric characters
  prefix = var.prefix

  # Environment Name used as suffix
  application = "aad"

  # Fully Qualified Environment Name
  name = "${local.prefix}-${local.application}"

  built_in_groups = [
    "${local.prefix}-application-management-owner",
    "${local.prefix}-cluster-management-owner",
    "${local.prefix}-archetype-management-owner",
    "${local.prefix}-c12-policy-security-owners",
    "${local.prefix}-c12-infrastructure-break-glass",
    "${local.prefix}-c12-infrastructure-sre",
    "${local.prefix}-c12-infrastructure-read-only",
  ]

  tags = {
    # Applicarion Name
    application = local.application
    # Workspace
    workspace = terraform.workspace
    # TF File Sources
    template = "src/components/identity-providers/aad"
    # Help identify resources created by terraform
    source = "terraform"
    # Protect this reource
    protected = true
  }

}

# Manage Builtin Repos
# Configure the Microsoft Azure Active Directory Provider

#Create AAD C12 Group
resource "azuread_group" "built_in_groups" {
  for_each = toset(local.built_in_groups)
  name     = each.value
}


#Create AAD C12 Group for github
resource "azuread_group" "app_dev" {
  for_each = var.applications == null ? [] : toset(var.applications)
  name     = "${local.prefix}-${each.value}-dev"
}
#Create AAD C12 Group
resource "azuread_group" "app_owner" {
  for_each = var.applications == null ? [] : toset(var.applications)
  name     = "${local.prefix}-${each.value}-owner"
}

#Create AAD C12 Groups for k8s
resource "azuread_group" "app_read_only" {
  for_each = var.applications == null ? [] : toset(var.applications)
  name     = "${local.prefix}-c12-${each.value}-read-only"
}

resource "azuread_group" "app_sre" {
  for_each = var.applications == null ? [] : toset(var.applications)
  name     = "${local.prefix}-c12-${each.value}-sre"
}

resource "azuread_group" "app_break_glass" {
  for_each = var.applications == null ? [] : toset(var.applications)
  name     = "${local.prefix}-c12-${each.value}-break-glass"
}
