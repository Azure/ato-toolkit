output "IMAGE_REPOSITORY_PASSWORD_ghsecret" {
  value = values(github_actions_secret.IMAGE_REPOSITORY_PASSWORD_ghsecret)[*].plaintext_value
}
output "IMAGE_REPOSITORY_USERNAME_ghsecret" {
  value = values(github_actions_secret.IMAGE_REPOSITORY_USERNAME_ghsecret)[*].plaintext_value
}

output "IMAGE_REPOSITORY_SP_ID_ghsecret" {
  value = values(github_actions_secret.IMAGE_REPOSITORY_SP_ID_ghsecret)[*].plaintext_value
}

output "AZURE_TENANT_ID_ghsecret" {
  value = values(github_actions_secret.AZURE_TENANT_ID_ghsecret)[*].plaintext_value
}

output "AZURE_SUBSCRIPTION_ID_ghsecret" {
  value = values(github_actions_secret.AZURE_SUBSCRIPTION_ID_ghsecret)[*].plaintext_value
}

output "CI_ACR_NAME_ghsecret" {
  value = values(github_actions_secret.CI_ACR_NAME_ghsecret)[*].plaintext_value
}

output "PAT_USERNAME_ghsecret" {
  value = values(github_actions_secret.PAT_USERNAME_ghsecret)[*].plaintext_value
}

output "PAT_TOKEN_ghsecret" {
  value = values(github_actions_secret.PAT_TOKEN_ghsecret)[*].plaintext_value
}

output "prefix_ghsecret" {
  value = values(github_actions_secret.prefix_ghsecret)[*].plaintext_value
}

output "org_ghsecret" {
  value = values(github_actions_secret.org_ghsecret)[*].plaintext_value
}

output "AZURE_TF_SP_CREDENTIALS_PASSWORD" {
  value = values(github_actions_secret.AZURE_TF_SP_CREDENTIALS_PASSWORD_ghsecret)[*].plaintext_value
}

output "AZURE_TF_SP_CREDENTIALS_APPID" {
  value = values(github_actions_secret.AZURE_TF_SP_CREDENTIALS_APPID_ghsecret)[*].plaintext_value
}
