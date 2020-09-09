locals {
  # Workspace Name used a prefix, limited to 6 alphanumeric characters
  prefix = var.prefix

  # Environment Name used as suffix
  application = "network"

  # Fully Qualified Environment Name
  name = "${local.prefix}-${local.application}"

  tags = {
    # Applicarion Name
    application = local.application
    # Workspace
    workspace = terraform.workspace
    # TF File Sources
    template = "src/components/infrastructure/azure/network"
    # Help identify resources created by terraform
    source = "terraform"
    # Protect this reource
    protected = true
  }
}

# Resources
data "azurerm_resource_group" "rg" {
  name = "${local.prefix}-c12-rg"
}

locals {
  // See https://aka.ms/aksegress
  // Rules numbered starting from 4000
  required_nsg_rules = {
    # "block_internet_out" : {
    #   priority                   = 4096
    #   access                     = "Deny"
    #   direction                  = "Outbound"
    #   protocol                   = "*"
    #   source_address_prefix      = "VirtualNetwork"
    #   destination_port_range     = "*"
    #   destination_address_prefix = "Internet"
    # }
    "MS_ACR" : {
      priority                   = 4011
      access                     = "Allow"
      direction                  = "Outbound"
      protocol                   = "*"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "MicrosoftContainerRegistry"
    },
    "Azure_ACR" : {
      priority                   = 4012
      access                     = "Allow"
      direction                  = "Outbound"
      protocol                   = "*"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "AzureContainerRegistry"
    },
    "Azure_APIs" : {
      priority                   = 4013
      access                     = "Allow"
      direction                  = "Outbound"
      protocol                   = "*"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "ApiManagement"
    },
    "Azure_Monitor" : {
      priority                   = 4014
      access                     = "Allow"
      direction                  = "Outbound"
      protocol                   = "*"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "AzureMonitor"
    },
    "Azure_Tunnelfront" : {
      priority               = 4015
      access                 = "Allow"
      direction              = "Outbound"
      protocol               = "Tcp"
      source_address_prefix  = "VirtualNetwork"
      destination_port_range = "9000"
    },
    "Azure_Tunnelfront" : {
      priority                   = 4016
      access                     = "Allow"
      direction                  = "Outbound"
      protocol                   = "Tcp"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "Storage"
    },
    "Azure_AAD" : {
      priority                   = 4017
      access                     = "Allow"
      direction                  = "Outbound"
      protocol                   = "Tcp"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "AzureActiveDirectory"
    },
    "Azure_LoadBalancer" : {
      priority                   = 4018
      access                     = "Allow"
      direction                  = "Outbound"
      protocol                   = "Tcp"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "AzureLoadBalancer"
    },
    "Azure_HttpTraffic_In" : {
      priority                   = 1000
      access                     = "Allow"
      direction                  = "Inbound"
      protocol                   = "Tcp"
      source_port_range          = "*"
      source_address_prefix      = "*"
      destination_port_range     = "80"
      destination_address_prefix = "*"
    },

  }
}

# Create the Virtual Network & Subnet
resource "azurerm_virtual_network" "network" {
  name                = local.name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  address_space       = [var.address_space]
  tags                = local.tags
}

resource "azurerm_subnet" "worker_subnet" {
  name                 = local.name
  resource_group_name  = data.azurerm_resource_group.rg.name
  address_prefix       = var.worker_address_prefix
  virtual_network_name = azurerm_virtual_network.network.name

  enforce_private_link_service_network_policies  = true
  enforce_private_link_endpoint_network_policies = true
  service_endpoints                              = ["Microsoft.ContainerRegistry"]
}

resource "azurerm_subnet" "jumphost_subnet" {
  name                 = "${local.name}-jumphost-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  address_prefix       = var.jumphost_address_prefix
  virtual_network_name = azurerm_virtual_network.network.name
}

resource "azurerm_subnet_network_security_group_association" "worker" {
  subnet_id                 = azurerm_subnet.worker_subnet.id
  network_security_group_id = azurerm_network_security_group.worker_nsg.id
}

resource "azurerm_network_security_group" "worker_nsg" {
  name                = "${local.name}-worker"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = local.tags
}

resource "azurerm_network_security_rule" "worker_allow_required_nsg_rules" {
  for_each = local.required_nsg_rules

  name                = "${each.key} ${each.value["direction"]}"
  resource_group_name = data.azurerm_resource_group.rg.name

  priority  = each.value["priority"]
  access    = lookup(each.value, "access", "Deny") // Fail safe when not specified.
  direction = each.value["direction"]
  protocol  = each.value["protocol"]
  source_address_prefix = lookup(
    each.value,
    "source_address_prefix",
    "*",
  )
  source_port_range = lookup(
    each.value,
    "source_port_range",
    "*",
  )
  destination_address_prefix = lookup(
    each.value,
    "destination_address_prefix",
    "*",
  )
  destination_port_range = lookup(
    each.value,
    "destination_port_range",
    "*",
  )

  # Providing a NSG here is DEPRECATED, however, if you use the recommended
  # azurerm_subnet_network_security_group_association resource, each subsequent
  # terraform apply will add/remove/add/remove/... the association.
  network_security_group_name = azurerm_network_security_group.worker_nsg.name
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

resource "azurerm_public_ip" "jumphost_pip" {
  name                    = "${local.name}-jumphost-pip"
  location                = data.azurerm_resource_group.rg.location
  resource_group_name     = data.azurerm_resource_group.rg.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30

  tags = local.tags
}

resource "azurerm_network_security_group" "jumphost_nsg" {
  name                = "${local.name}-jumphost-nsg"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = local.tags
}

resource "azurerm_subnet_network_security_group_association" "jumphost_nsg" {
  subnet_id                 = azurerm_subnet.jumphost_subnet.id
  network_security_group_id = azurerm_network_security_group.jumphost_nsg.id
}

resource "azurerm_network_security_rule" "allow_ssh" {
  name                = "Allow SSH Inbound"
  resource_group_name = data.azurerm_resource_group.rg.name

  priority  = 100
  direction = "Inbound"
  access    = "Allow"

  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.jumphost_nsg.name
}

resource "azurerm_network_interface" "jumphost_nic" {
  name                = "${local.name}-jumphost-nic"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = local.tags

  ip_configuration {
    name                          = "${local.name}-ip"
    subnet_id                     = azurerm_subnet.jumphost_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jumphost_pip.id
  }
}

resource "azurerm_virtual_machine" "jumphost" {
  name                = "${local.name}-jumphost"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  tags                = local.tags

  network_interface_ids = [azurerm_network_interface.jumphost_nic.id]
  vm_size               = "Standard_D2s_v3"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${local.name}-jumphost-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = local.name
    admin_username = "systemadmin"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      key_data = tls_private_key.ssh_key.public_key_openssh
      path     = "/home/systemadmin/.ssh/authorized_keys"
    }
  }
}

resource "azurerm_virtual_machine_extension" "aad_extension" {
  name               = "aad-login"
  tags               = local.tags
  virtual_machine_id = azurerm_virtual_machine.jumphost.id

  type                 = "AADLoginForLinux"
  publisher            = "Microsoft.Azure.ActiveDirectory.LinuxSSH"
  type_handler_version = "1.0"
}

data "azurerm_public_ip" "jumphost_pip" {
  name                = azurerm_public_ip.jumphost_pip.name
  resource_group_name = data.azurerm_resource_group.rg.name
  depends_on = [
    azurerm_virtual_machine.jumphost
  ]
}


# # Allow Administrator Login
# resource "azurerm_role_assignment" "admin_ra" {
#   role_definition_name = "Virtual Machine Administrator Login"
#   scope                = azurerm_virtual_machine.eu_onsite_jumpbox.id
#   principal_id         = var.team_object_id
# }

# # Allow User Login
# resource "azurerm_role_assignment" "user_ra" {
#   role_definition_name = "Virtual Machine User Login"
#   scope                = azurerm_virtual_machine.eu_onsite_jumpbox.id
#   principal_id         = var.team_object_id
# }
