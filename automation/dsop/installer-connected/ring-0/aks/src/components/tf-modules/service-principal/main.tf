# Generate a random password for use as the Service Principal Password
resource "random_string" "service_principal_password" {
  length  = 32
  special = true
}

# Create an AzureAD Application
resource "azuread_application" "application" {
  name = var.name
  # tags not supported by azuread_application
}

# Create an AzureAD service principal
resource "azuread_service_principal" "sp" {
  application_id = azuread_application.application.application_id
  # tags on azuread_service_principal are a list, rather than mapping
}

# Create an AzureAD service principal password
resource "azuread_service_principal_password" "spp" {
  service_principal_id = azuread_service_principal.sp.id
  value                = random_string.service_principal_password.result

  # TODO: How to handle expiry and rotation?
  end_date_relative = "1024h"

  # tags not supported by azuread_service_principal_password

  # workaround as sugested in https://github.com/terraform-providers/terraform-provider-azuread/issues/4  as the az ad was not working.
  # this seems to be a replication latency issue. If not applied, the K8 cluster won't get randomly provisioned as the SP is not replicated on time.
  provisioner "local-exec" {
    command = <<EOF
      sleep 120
EOF

  }
}
