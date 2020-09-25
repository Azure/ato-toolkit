locals {
  # Workspace Name used a prefix, limited to 6 alphanumeric characters
  prefix = var.prefix

  # Environment Name used as suffix
  application = "github-enterprise-cloud"

  # Fully Qualified Environment Name
  name = "${local.prefix}-${local.application}"

  built_in_teams = [
    "${local.prefix}-application-management-owner",
    "${local.prefix}-cluster-management-owner",
    "${local.prefix}-archetype-management-owner",
  ]
}

# Manage Builtin Teams

data "azuread_group" "built_in_groups" {
  for_each = toset(local.built_in_teams)
  name     = each.value
}

data "azuread_group" "app_dev" {
  for_each = var.applications == null ? [] : toset(var.applications)
  name     = "${local.prefix}-${each.value}-dev"
}

data "azuread_group" "app_owner" {
  for_each = var.applications == null ? [] : toset(var.applications)
  name     = "${local.prefix}-${each.value}-owner"
}

resource "github_team" "built_in_team" {
  for_each = toset(local.built_in_teams)
  name     = each.value
  privacy  = "closed"
}

resource "github_team_sync_group_mapping" "built_in_team_aad_sync" {
  for_each  = toset(local.built_in_teams)
  team_slug = each.value
  group {
    group_id          = data.azuread_group.built_in_groups[each.value].id
    group_name        = each.value
    group_description = ""
  }
}

resource "github_team_repository" "app_mgmt_owner" {
  team_id    = github_team.built_in_team["${local.prefix}-application-management-owner"].id
  repository = "${local.prefix}-application-management"
  permission = "maintain"
}

resource "github_team_repository" "cluster-management_owner" {
  team_id    = github_team.built_in_team["${local.prefix}-cluster-management-owner"].id
  repository = "${local.prefix}-cluster-management"
  permission = "maintain"
}

resource "github_team_repository" "archetype-management_owner" {
  team_id    = github_team.built_in_team["${local.prefix}-archetype-management-owner"].id
  repository = "${local.prefix}-archetype-management"
  permission = "maintain"
}

# Manage Per repos and teams

resource "github_team" "dev_team" {
  for_each = var.applications == null ? [] : toset(var.applications)
  name     = "${local.prefix}-${each.value}-dev"
  privacy  = "closed"
}

resource "github_team_sync_group_mapping" "dev_team_aad_sync" {
  for_each  = var.applications == null ? [] : toset(var.applications)
  team_slug = "${local.prefix}-${each.value}-dev"
  group {
    group_id          = data.azuread_group.app_dev[each.value].id
    group_name        = each.value
    group_description = ""
  }
}

resource "github_team_repository" "dev_team_src_repo" {
  for_each   = var.applications == null ? [] : toset(var.applications)
  team_id    = github_team.dev_team[each.value].id
  repository = "${local.prefix}-${each.value}-src"
  permission = "triage"
}


resource "github_team" "owner_team" {
  for_each = var.applications == null ? [] : toset(var.applications)
  name     = "${local.prefix}-${each.value}-owner"
  privacy  = "closed"
}

resource "github_team_sync_group_mapping" "owner_team_aad_sync" {
  for_each  = var.applications == null ? [] : toset(var.applications)
  team_slug = "${local.prefix}-${each.value}-owner"
  group {
    group_id          = data.azuread_group.app_owner[each.value].id
    group_name        = each.value
    group_description = ""
  }
}

resource "github_team_repository" "owner_team_src_repo" {
  for_each   = var.applications == null ? [] : toset(var.applications)
  team_id    = github_team.owner_team[each.value].id
  repository = "${local.prefix}-${each.value}-src"
  permission = "pull"
}
