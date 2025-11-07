data "azurerm_client_config" "current" {}

# Root Management Group
resource "azurerm_management_group" "root" {
  display_name = "${var.organization_name}-${var.root_management_group_name}"
  name         = "${var.organization_name}-root"
}

# Platform Management Group
resource "azurerm_management_group" "platform" {
  display_name               = "${var.organization_name}-Platform"
  name                       = "${var.organization_name}-platform"
  parent_management_group_id = azurerm_management_group.root.id
}

# Platform - Management
resource "azurerm_management_group" "platform_management" {
  display_name               = "${var.organization_name}-Platform-Management"
  name                       = "${var.organization_name}-platform-mgmt"
  parent_management_group_id = azurerm_management_group.platform.id
}

# Platform - Connectivity
resource "azurerm_management_group" "platform_connectivity" {
  display_name               = "${var.organization_name}-Platform-Connectivity"
  name                       = "${var.organization_name}-platform-conn"
  parent_management_group_id = azurerm_management_group.platform.id
}

# Platform - Identity
resource "azurerm_management_group" "platform_identity" {
  display_name               = "${var.organization_name}-Platform-Identity"
  name                       = "${var.organization_name}-platform-id"
  parent_management_group_id = azurerm_management_group.platform.id
}

# Landing Zones Management Group
resource "azurerm_management_group" "landing_zones" {
  display_name               = "${var.organization_name}-Landing-Zones"
  name                       = "${var.organization_name}-lz"
  parent_management_group_id = azurerm_management_group.root.id
}

# Landing Zones - Production
resource "azurerm_management_group" "landing_zones_prod" {
  display_name               = "${var.organization_name}-Landing-Zones-Production"
  name                       = "${var.organization_name}-lz-prod"
  parent_management_group_id = azurerm_management_group.landing_zones.id
}

# Landing Zones - Development
resource "azurerm_management_group" "landing_zones_dev" {
  display_name               = "${var.organization_name}-Landing-Zones-Development"
  name                       = "${var.organization_name}-lz-dev"
  parent_management_group_id = azurerm_management_group.landing_zones.id
}

# Sandbox Management Group
resource "azurerm_management_group" "sandbox" {
  display_name               = "${var.organization_name}-Sandbox"
  name                       = "${var.organization_name}-sandbox"
  parent_management_group_id = azurerm_management_group.root.id
}

# Decommissioned Management Group
resource "azurerm_management_group" "decomissioned" {
  display_name               = "${var.organization_name}-Decommissioned"
  name                       = "${var.organization_name}-decomm"
  parent_management_group_id = azurerm_management_group.root.id
}
