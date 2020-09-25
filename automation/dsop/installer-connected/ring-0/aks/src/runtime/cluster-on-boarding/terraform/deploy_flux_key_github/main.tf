locals {
  # Workspace Name used a prefix, limited to 6 alphanumeric characters
  prefix      = var.prefix
  application = var.application
  repo_name   = "${local.prefix}-${var.repository}"

}

# Add a deploy key
resource "github_repository_deploy_key" "flux-admin-c12-flux" {
  title      = "${var.cluster_name} ${local.application}"
  repository = local.repo_name
  key        = file("${var.ssh_pub_key}")
  read_only  = "true"
}
