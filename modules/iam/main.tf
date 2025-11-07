data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

# Built-in Role Definitions Reference
data "azurerm_role_definition" "contributor" {
  name = "Contributor"
}

data "azurerm_role_definition" "reader" {
  name = "Reader"
}

data "azurerm_role_definition" "owner" {
  name = "Owner"
}

# Custom Role Definition - Network Contributor
resource "azurerm_role_definition" "network_contributor" {
  name        = "Custom Network Contributor"
  scope       = var.management_group_id
  description = "Can manage network resources but cannot grant access to others"

  permissions {
    actions = [
      "Microsoft.Network/*",
      "Microsoft.Resources/subscriptions/resourceGroups/read",
      "Microsoft.Resources/deployments/*",
      "Microsoft.Authorization/*/read",
    ]
    not_actions = [
      "Microsoft.Authorization/*/write",
      "Microsoft.Authorization/*/delete",
    ]
  }

  assignable_scopes = [
    var.management_group_id,
  ]
}

# Custom Role Definition - Security Reader Plus
resource "azurerm_role_definition" "security_reader_plus" {
  name        = "Custom Security Reader Plus"
  scope       = var.management_group_id
  description = "Can view security settings and policies, and read security reports"

  permissions {
    actions = [
      "Microsoft.Security/*/read",
      "Microsoft.SecurityInsights/*/read",
      "Microsoft.Authorization/policyDefinitions/read",
      "Microsoft.Authorization/policyAssignments/read",
      "Microsoft.Authorization/policySetDefinitions/read",
      "Microsoft.Resources/subscriptions/resourceGroups/read",
      "Microsoft.OperationalInsights/workspaces/read",
      "Microsoft.OperationalInsights/workspaces/query/read",
    ]
    not_actions = []
  }

  assignable_scopes = [
    var.management_group_id,
  ]
}

# Custom Role Definition - Cost Management Reader
resource "azurerm_role_definition" "cost_management_reader" {
  name        = "Custom Cost Management Reader"
  scope       = var.management_group_id
  description = "Can view cost data and budgets"

  permissions {
    actions = [
      "Microsoft.Consumption/*/read",
      "Microsoft.CostManagement/*/read",
      "Microsoft.Billing/*/read",
      "Microsoft.Resources/subscriptions/read",
      "Microsoft.Resources/subscriptions/resourceGroups/read",
    ]
    not_actions = []
  }

  assignable_scopes = [
    var.management_group_id,
  ]
}

# RBAC Role Assignments at Management Group Level
resource "azurerm_role_assignment" "custom" {
  for_each = var.rbac_assignments

  scope                = var.management_group_id
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id

  skip_service_principal_aad_check = try(each.value.skip_service_principal_check, false)
}

# Azure AD Groups for Landing Zone (example structure)
# Note: These are optional and require appropriate Azure AD permissions

# Security Groups
resource "azuread_group" "platform_admins" {
  count = var.create_ad_groups ? 1 : 0

  display_name     = "${var.organization_name}-Platform-Admins"
  description      = "Administrators for platform resources"
  security_enabled = true
}

resource "azuread_group" "network_admins" {
  count = var.create_ad_groups ? 1 : 0

  display_name     = "${var.organization_name}-Network-Admins"
  description      = "Administrators for network resources"
  security_enabled = true
}

resource "azuread_group" "security_team" {
  count = var.create_ad_groups ? 1 : 0

  display_name     = "${var.organization_name}-Security-Team"
  description      = "Security team members"
  security_enabled = true
}

resource "azuread_group" "developers" {
  count = var.create_ad_groups ? 1 : 0

  display_name     = "${var.organization_name}-Developers"
  description      = "Development team members"
  security_enabled = true
}

# Role Assignments for AD Groups
resource "azurerm_role_assignment" "platform_admins" {
  count = var.create_ad_groups ? 1 : 0

  scope                = var.management_group_id
  role_definition_name = "Owner"
  principal_id         = azuread_group.platform_admins[0].object_id
}

resource "azurerm_role_assignment" "network_admins" {
  count = var.create_ad_groups ? 1 : 0

  scope              = var.management_group_id
  role_definition_id = azurerm_role_definition.network_contributor.role_definition_resource_id
  principal_id       = azuread_group.network_admins[0].object_id
}

resource "azurerm_role_assignment" "security_team" {
  count = var.create_ad_groups ? 1 : 0

  scope              = var.management_group_id
  role_definition_id = azurerm_role_definition.security_reader_plus.role_definition_resource_id
  principal_id       = azuread_group.security_team[0].object_id
}

resource "azurerm_role_assignment" "developers" {
  count = var.create_ad_groups ? 1 : 0

  scope                = var.management_group_id
  role_definition_name = "Contributor"
  principal_id         = azuread_group.developers[0].object_id
}
