output "management_groups" {
  description = "Management group hierarchy"
  value = {
    root_id           = module.management_groups.root_management_group_id
    platform_id       = module.management_groups.platform_management_group_id
    landing_zones_id  = module.management_groups.landing_zones_management_group_id
    sandbox_id        = module.management_groups.sandbox_management_group_id
  }
}

output "network" {
  description = "Network configuration"
  value = {
    hub_vnet_id         = module.network.hub_vnet_id
    hub_vnet_name       = module.network.hub_vnet_name
    spoke_vnet_ids      = module.network.spoke_vnet_ids
    hub_subnet_ids      = module.network.hub_subnet_ids
  }
  sensitive = false
}

output "log_analytics_workspace" {
  description = "Log Analytics workspace information"
  value = {
    id                  = module.security_monitoring.log_analytics_workspace_id
    workspace_id        = module.security_monitoring.log_analytics_workspace_workspace_id
    name                = module.security_monitoring.log_analytics_workspace_name
  }
  sensitive = true
}

output "key_vault" {
  description = "Key Vault information"
  value = {
    id   = module.shared_services.key_vault_id
    name = module.shared_services.key_vault_name
    uri  = module.shared_services.key_vault_uri
  }
}

output "resource_groups" {
  description = "Resource groups created"
  value = {
    network        = var.network_resource_group_name
    security       = var.security_resource_group_name
    shared_services = var.shared_services_resource_group_name
  }
}
