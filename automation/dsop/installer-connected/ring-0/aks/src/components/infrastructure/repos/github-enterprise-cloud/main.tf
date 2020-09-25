locals {
  # Workspace Name used a prefix, limited to 6 alphanumeric characters
  prefix = var.prefix

  # Environment Name used as suffix
  application = "github-enterprise-cloud"

  # Fully Qualified Environment Name
  name = "${local.prefix}-${local.application}"

  built_in_repos = ["application-management", "cluster-management", "cluster-state", "archetype-management"]


}

# Manage Builtin Repos
resource "github_repository" "built_in_repos" {
  for_each = toset(local.built_in_repos)
  name     = "${local.prefix}-${each.value}"
  private  = true
}

# Manage Per Applicaiion repos
resource "github_repository" "app_src_repos" {
  for_each = var.applications == null ? [] : toset(var.applications)
  name     = "${local.prefix}-${each.value}-src"
  private  = true
}


resource "github_repository" "app_state_repos" {
  for_each = var.applications == null ? [] : toset(var.applications)
  name     = "${local.prefix}-${each.value}-state"
  private  = true
}

