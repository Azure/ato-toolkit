locals {
  # Workspace Name used a prefix, limited to 6 alphanumeric characters
  prefix       = var.prefix
  applications = var.applications == null ? [] : toset(var.applications)
}

# Add a deploy key
resource "github_repository_deploy_key" "flux-app-c12-flux" {
  for_each   = local.applications
  title      = "App ${each.key} flux key"
  repository = "${local.prefix}-${each.key}-state"
  key        = tls_private_key.ssh_key[each.key].public_key_openssh
  read_only  = "true"
}

resource "tls_private_key" "ssh_key" {
  for_each   = local.applications
  algorithm  = "RSA"
  rsa_bits   = 4096
}


output "application-secret-mappings" {
  value = [
    for app_name, ssh_key in zipmap(
      sort(local.applications),
      sort(values(tls_private_key.ssh_key)[*]["private_key_pem"])) :
      map("name", app_name, "ssh_key", ssh_key)
  ]
}