
data "azurerm_subscription" "current" {
}

data "azurerm_container_registry" "ci_acr" {
  name                = var.ci_acr_name
  resource_group_name = "${var.prefix}-c12-rg"
}

# rbac sp
resource "azuread_application" "sp_application" {
  for_each = var.repositories == null ? [] : toset(var.repositories)
  name                       = "${each.key}-sp"
  available_to_other_tenants = false

  # Microsoft Graph
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"

    # AppRoleAssignment.ReadWrite.All
    resource_access {
      id = "06b708a9-e830-4db3-a914-8e69da51d44f"
      type = "Role"
    }
    # Directory.ReadWrite.All
    resource_access {
      id = "19dbc75e-c2e2-444c-a770-ec69d8559fc7"
      type = "Role"
    }
	}
  

  # Microsoft AAD
  required_resource_access {
    resource_app_id = "00000002-0000-0000-c000-000000000000"

    # Directory.ReadWrite.All within the Windows Azure Active Directory API
    resource_access {
      id = "78c8a3c8-a07e-4b9e-af1b-b5ccab50a175"
      type = "Role"
    }
    # Application.ReadWrite.All within the Windows Azure Active Directory API
    resource_access {
      id = "1cda74f2-2616-4834-b122-5cb1b07f8a59"
      type = "Role"
    }
  }

}

resource "random_password" "sp_password" {
  for_each = var.repositories == null ? [] : toset(var.repositories)
  length   = 16
  special  = true
}

resource "azuread_service_principal" "sp" {
  for_each       = var.repositories == null ? [] : toset(var.repositories)
  application_id = azuread_application.sp_application[each.key].application_id
}

# Create role assignment for service principal
resource "azurerm_role_assignment" "owner" {
  for_each             = var.repositories == null ? [] : toset(var.repositories)
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Owner"
  principal_id         = azuread_service_principal.sp[each.key].id
}

resource "azuread_application_password" "sp_password" {
  for_each              = var.repositories == null ? [] : toset(var.repositories)
  application_object_id = azuread_application.sp_application[each.key].object_id
  value                 = random_password.sp_password[each.key].result
  end_date_relative     = "17520h" #expire in 2 years
}


# Before giving consent, wait. Sometimes Azure returns a 200, but not all services have access to the newly created applications/services.
resource "null_resource" "delay_before_consent" {
  provisioner "local-exec" {
    command = "sleep 60"
  }
  depends_on = [
    azuread_service_principal.sp,
  ]
}


# Give admin consent - SP/az login user must be AAD admin
resource "null_resource" "grant_sp_consent_constent" {
   for_each = var.repositories == null ? [] : toset(var.repositories)
   provisioner "local-exec" {
      command = "./post_grant_request.sh"
      environment = {
        SP_APP_ID = azuread_application.sp_application[each.key].application_id
        SP_ID = azuread_service_principal.sp[each.key].object_id
      }
    }
 
    depends_on = [
      null_resource.delay_before_consent
    ]
}

# Again, wait for a few seconds...
resource "null_resource" "delay" {
  provisioner "local-exec" {
    command = "sleep 60"
  }
  depends_on = [
    null_resource.grant_sp_consent_constent
  ]
}

# Github sercets

resource "github_actions_secret" "IMAGE_REPOSITORY_PASSWORD_ghsecret" {
  for_each        = var.repositories == null ? [] : toset(var.repositories)
  repository      = each.key
  secret_name     = "IMAGE_REPOSITORY_PASSWORD"
  plaintext_value = azuread_application_password.sp_password[each.key].value
}

resource "github_actions_secret" "IMAGE_REPOSITORY_USERNAME_ghsecret" {
  for_each        = var.repositories == null ? [] : toset(var.repositories)
  repository      = each.key
  secret_name     = "IMAGE_REPOSITORY_USERNAME"
  plaintext_value = azuread_application.sp_application[each.key].application_id
}

resource "github_actions_secret" "IMAGE_REPOSITORY_SP_ID_ghsecret" {
  for_each        = var.repositories == null ? [] : toset(var.repositories)
  repository      = each.key
  secret_name     = "IMAGE_REPOSITORY_SP_ID"
  plaintext_value = azuread_service_principal.sp[each.key].id
}

resource "github_actions_secret" "AZURE_TF_SP_CREDENTIALS_PASSWORD_ghsecret" {
  for_each        = var.repositories == null ? [] : toset(var.repositories)
  repository      = each.key
  secret_name     = "AZURE_TF_SP_CREDENTIALS_PASSWORD"
  plaintext_value = azuread_application_password.sp_password[each.key].value
}

resource "github_actions_secret" "AZURE_TF_SP_CREDENTIALS_APPID_ghsecret" {
  for_each        = var.repositories == null ? [] : toset(var.repositories)
  repository      = each.key
  secret_name     = "AZURE_TF_SP_CREDENTIALS_APPID"
  plaintext_value = azuread_application.sp_application[each.key].application_id
}

resource "github_actions_secret" "AZURE_TENANT_ID_ghsecret" {
  for_each        = var.repositories == null ? [] : toset(var.repositories)
  repository      = each.key
  secret_name     = "AZURE_TENANT_ID"
  plaintext_value = data.azurerm_subscription.current.tenant_id
}
resource "github_actions_secret" "AZURE_SUBSCRIPTION_ID_ghsecret" {
  for_each        = var.repositories == null ? [] : toset(var.repositories)
  repository      = each.key
  secret_name     = "AZURE_SUBSCRIPTION_ID"
  plaintext_value = data.azurerm_subscription.current.subscription_id
}

resource "github_actions_secret" "CI_ACR_NAME_ghsecret" {
  for_each        = var.repositories == null ? [] : toset(var.repositories)
  repository      = each.key
  secret_name     = "CI_ACR_NAME"
  plaintext_value = var.ci_acr_name
}

resource "github_actions_secret" "PAT_USERNAME_ghsecret" {
  for_each        = var.repositories == null ? [] : toset(var.repositories)
  repository      = each.key
  secret_name     = "PAT_USERNAME"
  plaintext_value = var.access_token_username
}

resource "github_actions_secret" "PAT_TOKEN_ghsecret" {
  for_each        = var.repositories == null ? [] : toset(var.repositories)
  repository      = each.key
  secret_name     = "PAT_TOKEN"
  plaintext_value = var.access_token
}

resource "github_actions_secret" "prefix_ghsecret" {
  for_each        = var.repositories == null ? [] : toset(var.repositories)
  repository      = each.key
  secret_name     = "PREFIX"
  plaintext_value = var.prefix
}

resource "github_actions_secret" "org_ghsecret" {
  for_each        = var.repositories == null ? [] : toset(var.repositories)
  repository      = each.key
  secret_name     = "ORG"
  plaintext_value = var.org
}