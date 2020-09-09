output "ssh_key_location" {
  value = local_file.private_ssh_key.filename
}

output "service_principal_id" {
  value = module.service_principal.id
}

output "service_principal_application_id" {
  value = module.service_principal.application_id
}

output "service_principal_password" {
  value = module.service_principal.password
}

output "regional_acr_name" {
  value = module.acr.name
}

output "ci_acr_name" {
  value = module.dev_acr.name
}

output "aks_name" {
  value = local.name
}

output "disk_encryption_set_id" {
  value = module.disk_encryption_set.disk_encryption_set_id
}