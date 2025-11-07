output "custom_role_definition_ids" {
  description = "IDs of custom role definitions"
  value = {
    network_contributor      = azurerm_role_definition.network_contributor.role_definition_resource_id
    security_reader_plus     = azurerm_role_definition.security_reader_plus.role_definition_resource_id
    cost_management_reader   = azurerm_role_definition.cost_management_reader.role_definition_resource_id
  }
}

output "ad_group_ids" {
  description = "Object IDs of created Azure AD groups"
  value = var.create_ad_groups ? {
    platform_admins = azuread_group.platform_admins[0].object_id
    network_admins  = azuread_group.network_admins[0].object_id
    security_team   = azuread_group.security_team[0].object_id
    developers      = azuread_group.developers[0].object_id
  } : {}
}

output "role_assignment_ids" {
  description = "IDs of role assignments"
  value = {
    for k, v in azurerm_role_assignment.custom : k => v.id
  }
}
