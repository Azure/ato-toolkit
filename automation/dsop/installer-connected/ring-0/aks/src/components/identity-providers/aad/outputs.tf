output "aad_groups" {
  value = azuread_group.built_in_groups
}

output "break_glass_id" {
  value = azuread_group.built_in_groups["${local.prefix}-c12-infrastructure-break-glass"].id
}

output "read_only_id" {
  value = azuread_group.built_in_groups["${local.prefix}-c12-infrastructure-read-only"].id
}

output "sre_id" {
  value = azuread_group.built_in_groups["${local.prefix}-c12-infrastructure-sre"].id
}
