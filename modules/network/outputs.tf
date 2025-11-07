output "resource_group_id" {
  description = "ID of the network resource group"
  value       = azurerm_resource_group.network.id
}

output "hub_vnet_id" {
  description = "ID of the hub virtual network"
  value       = azurerm_virtual_network.hub.id
}

output "hub_vnet_name" {
  description = "Name of the hub virtual network"
  value       = azurerm_virtual_network.hub.name
}

output "hub_subnet_ids" {
  description = "IDs of hub subnets"
  value       = { for k, v in azurerm_subnet.hub : k => v.id }
}

output "spoke_vnet_ids" {
  description = "IDs of spoke virtual networks"
  value       = { for k, v in azurerm_virtual_network.spoke : k => v.id }
}

output "spoke_vnet_names" {
  description = "Names of spoke virtual networks"
  value       = { for k, v in azurerm_virtual_network.spoke : k => v.name }
}

output "spoke_subnet_ids" {
  description = "IDs of spoke subnets"
  value       = { for k, v in azurerm_subnet.spoke : k => v.id }
}

output "bastion_id" {
  description = "ID of the Bastion host"
  value       = try(azurerm_bastion_host.bastion[0].id, null)
}

output "bastion_dns_name" {
  description = "DNS name of the Bastion host"
  value       = try(azurerm_bastion_host.bastion[0].dns_name, null)
}
