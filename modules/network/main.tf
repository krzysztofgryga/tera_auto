data "azurerm_client_config" "current" {}

# Resource Group for Network
resource "azurerm_resource_group" "network" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Hub Virtual Network
resource "azurerm_virtual_network" "hub" {
  name                = var.hub_vnet_config.name
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  address_space       = var.hub_vnet_config.address_space
  tags                = var.tags
}

# Hub Subnets
resource "azurerm_subnet" "hub" {
  for_each = var.hub_vnet_config.subnets

  name                 = each.key
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [each.value.address_prefix]
  service_endpoints    = try(each.value.service_endpoints, [])
}

# Network Security Group for Hub
resource "azurerm_network_security_group" "hub" {
  name                = "nsg-${var.hub_vnet_config.name}"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  tags                = var.tags

  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Spoke Virtual Networks
resource "azurerm_virtual_network" "spoke" {
  for_each = var.spoke_vnets

  name                = each.value.name
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  address_space       = each.value.address_space
  tags                = merge(var.tags, { Environment = each.key })
}

# Spoke Subnets
resource "azurerm_subnet" "spoke" {
  for_each = merge([
    for spoke_key, spoke_config in var.spoke_vnets : {
      for subnet_key, subnet_config in spoke_config.subnets :
      "${spoke_key}-${subnet_key}" => {
        spoke_key      = spoke_key
        subnet_key     = subnet_key
        subnet_config  = subnet_config
        vnet_name      = spoke_config.name
      }
    }
  ]...)

  name                 = each.value.subnet_key
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.spoke[each.value.spoke_key].name
  address_prefixes     = [each.value.subnet_config.address_prefix]
  service_endpoints    = try(each.value.subnet_config.service_endpoints, [])
}

# Network Security Groups for Spokes
resource "azurerm_network_security_group" "spoke" {
  for_each = var.spoke_vnets

  name                = "nsg-${each.value.name}"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  tags                = merge(var.tags, { Environment = each.key })

  security_rule {
    name                       = "AllowHubInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefixes    = var.hub_vnet_config.address_space
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Hub-to-Spoke VNet Peerings
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  for_each = var.spoke_vnets

  name                         = "peer-${var.hub_vnet_config.name}-to-${each.value.name}"
  resource_group_name          = azurerm_resource_group.network.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke[each.key].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
}

# Spoke-to-Hub VNet Peerings
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  for_each = var.spoke_vnets

  name                         = "peer-${each.value.name}-to-${var.hub_vnet_config.name}"
  resource_group_name          = azurerm_resource_group.network.name
  virtual_network_name         = azurerm_virtual_network.spoke[each.key].name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  use_remote_gateways          = false
}

# Azure Bastion Public IP (optional)
resource "azurerm_public_ip" "bastion" {
  count = contains(keys(var.hub_vnet_config.subnets), "AzureBastionSubnet") ? 1 : 0

  name                = "pip-bastion"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Azure Bastion Host (optional)
resource "azurerm_bastion_host" "bastion" {
  count = contains(keys(var.hub_vnet_config.subnets), "AzureBastionSubnet") ? 1 : 0

  name                = "bastion-hub"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  tags                = var.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.hub["AzureBastionSubnet"].id
    public_ip_address_id = azurerm_public_ip.bastion[0].id
  }
}

# DDoS Protection Plan (optional, can be expensive)
resource "azurerm_network_ddos_protection_plan" "ddos" {
  count = var.enable_ddos_protection ? 1 : 0

  name                = "ddos-protection-plan"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  tags                = var.tags
}
