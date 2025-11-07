output "root_management_group_id" {
  description = "ID of the root management group"
  value       = azurerm_management_group.root.id
}

output "platform_management_group_id" {
  description = "ID of the platform management group"
  value       = azurerm_management_group.platform.id
}

output "platform_management_id" {
  description = "ID of the platform management sub-group"
  value       = azurerm_management_group.platform_management.id
}

output "platform_connectivity_id" {
  description = "ID of the platform connectivity sub-group"
  value       = azurerm_management_group.platform_connectivity.id
}

output "platform_identity_id" {
  description = "ID of the platform identity sub-group"
  value       = azurerm_management_group.platform_identity.id
}

output "landing_zones_management_group_id" {
  description = "ID of the landing zones management group"
  value       = azurerm_management_group.landing_zones.id
}

output "landing_zones_prod_id" {
  description = "ID of the landing zones production sub-group"
  value       = azurerm_management_group.landing_zones_prod.id
}

output "landing_zones_dev_id" {
  description = "ID of the landing zones development sub-group"
  value       = azurerm_management_group.landing_zones_dev.id
}

output "sandbox_management_group_id" {
  description = "ID of the sandbox management group"
  value       = azurerm_management_group.sandbox.id
}

output "decommissioned_management_group_id" {
  description = "ID of the decommissioned management group"
  value       = azurerm_management_group.decomissioned.id
}
