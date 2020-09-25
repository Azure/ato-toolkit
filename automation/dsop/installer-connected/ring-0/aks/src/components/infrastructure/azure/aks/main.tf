locals {
  # Workspace Name used a prefix, limited to 6 alphanumeric characters
  prefix = var.prefix

  # Environment Name used as suffix
  application = "aks"

  # Fully Qualified Environment Name
  name = "${local.prefix}-${var.location}-01"

  tags = {
    # Applicarion Name
    application = local.application
    # Workspace
    workspace = terraform.workspace
    # TF File Sources
    template = "src/components/infrastructure/azure/aks"
    # Help identify resources created by terraform
    source = "terraform"
    # Protect this reource
    protected = true
  }
}

module "aad_application" {
  source      = "../../../tf-modules/aad-application"
  clustername = "${local.name}-${local.application}"
}

module "service_principal" {
  source = "../../../tf-modules/service-principal"
  tags   = local.tags
  name   = "${local.name}-${local.application}"
}

# Resources
data "azurerm_resource_group" "rg" {
  name = "${local.prefix}-c12-rg"
}

data "terraform_remote_state" "network" {
  backend = "azurerm"

  config = {
    key                  = "azure/network.tfstate"
    storage_account_name = var.storage_account_name
    container_name       = var.container_name
    resource_group_name  = var.resource_group_name
  }
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_ssh_key" {
  sensitive_content = tls_private_key.ssh_key.private_key_pem
  filename          = "id_rsa"
  file_permission   = 600
}

resource "azurerm_role_assignment" "vnet_spn_role_assn" {
  role_definition_name = "Network Contributor"
  scope                = data.terraform_remote_state.network.outputs.vnet_id
  principal_id         = module.service_principal.id
}


# Create the AKS cluster
resource "azurerm_kubernetes_cluster" "k8_cluster" {
  name                 = local.name
  dns_prefix           = local.name
  location             = var.location
  resource_group_name  = data.azurerm_resource_group.rg.name
  kubernetes_version   = var.kubernetes_version
  private_link_enabled = true

  linux_profile {
    admin_username = var.admin_username

    ssh_key {
      key_data = tls_private_key.ssh_key.public_key_openssh
    }
  }

  default_node_pool {
    name                = format("%.9s", replace(lower(local.name), "/[^a-z0-9]/", ""))
    vm_size             = "Standard_DS2_v2"
    vnet_subnet_id      = data.terraform_remote_state.network.outputs.subnet_id
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = true
    min_count           = 3
    max_count           = 12
    node_count          = 3
  }

  service_principal {
    client_id     = module.service_principal.application_id
    client_secret = module.service_principal.password
  }

  network_profile {
    network_plugin     = "azure"
    network_policy     = "calico"
    docker_bridge_cidr = var.docker_bridge_cidr
    dns_service_ip     = var.dns_service_ip
    service_cidr       = var.service_cidr
    load_balancer_sku  = "Standard"
  }

  addon_profile {
    azure_policy {
      enabled = true
    }
    kube_dashboard {
      enabled = true
    }
  }

  role_based_access_control {
    enabled = true
    azure_active_directory {
      client_app_id     = module.aad_application.client_app_id
      server_app_id     = module.aad_application.server_app_id
      server_app_secret = module.aad_application.server_app_secret
      tenant_id         = module.aad_application.tenant_id
    }
  }

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count,

      # we dont have any windows nodes, but not setting this causes later runs to
      # re create the cluster, which is not great - when https://github.com/terraform-providers/terraform-provider-azurerm/issues/6235 is fixed we can remove this

      windows_profile
    ]
  }

  tags = local.tags
}

module "acr" {
  source              = "../../../tf-modules/acr"
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = local.tags
  name                = "${var.prefix}${var.location}clusteracr"
  principal_ids       = []
  worker_subnet_id    = data.terraform_remote_state.network.outputs.subnet_id
}

# ACR registry with the images shared images
module "aks_acr_binding" {
  source                   = "../../../tf-modules/aks-external-registry"
  acr_id                   = module.acr.id
  aks_service_principal_id = module.service_principal.id
}

# Dev ACR for pushing builds from application-src repos, before they are deployed to a cluster
module "dev_acr" {
  source              = "../../../tf-modules/acr"
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = local.tags
  name                = "${var.prefix}ciacr"
  principal_ids       = []
  worker_subnet_id    = data.terraform_remote_state.network.outputs.subnet_id
}

module "disk_encryption_set" {
  source              = "../../../tf-modules/encrypted_disk_set"
  prefix              = var.prefix
}