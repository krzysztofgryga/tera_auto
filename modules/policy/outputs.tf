output "policy_definition_ids" {
  description = "IDs of custom policy definitions"
  value = {
    require_tags        = azurerm_policy_definition.require_tags.id
    allowed_locations   = azurerm_policy_definition.allowed_locations.id
    require_encryption  = azurerm_policy_definition.require_encryption.id
  }
}

output "policy_set_definition_ids" {
  description = "IDs of policy set definitions"
  value = {
    security_baseline = azurerm_policy_set_definition.security_baseline.id
  }
}

output "policy_assignment_ids" {
  description = "IDs of policy assignments"
  value = {
    require_tags       = azurerm_management_group_policy_assignment.require_tags.id
    allowed_locations  = azurerm_management_group_policy_assignment.allowed_locations.id
    deploy_asc         = azurerm_management_group_policy_assignment.deploy_asc.id
    deploy_diagnostics = azurerm_management_group_policy_assignment.deploy_diagnostics.id
    security_baseline  = azurerm_management_group_policy_assignment.security_baseline.id
  }
}
