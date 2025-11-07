data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

# Resource Group for Security and Monitoring
resource "azurerm_resource_group" "security" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-${var.resource_group_name}"
  location            = azurerm_resource_group.security.location
  resource_group_name = azurerm_resource_group.security.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_analytics_retention_days
  tags                = var.tags
}

# Log Analytics Solutions
resource "azurerm_log_analytics_solution" "security" {
  solution_name         = "Security"
  location              = azurerm_resource_group.security.location
  resource_group_name   = azurerm_resource_group.security.name
  workspace_resource_id = azurerm_log_analytics_workspace.main.id
  workspace_name        = azurerm_log_analytics_workspace.main.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Security"
  }

  tags = var.tags
}

resource "azurerm_log_analytics_solution" "updates" {
  solution_name         = "Updates"
  location              = azurerm_resource_group.security.location
  resource_group_name   = azurerm_resource_group.security.name
  workspace_resource_id = azurerm_log_analytics_workspace.main.id
  workspace_name        = azurerm_log_analytics_workspace.main.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Updates"
  }

  tags = var.tags
}

resource "azurerm_log_analytics_solution" "change_tracking" {
  solution_name         = "ChangeTracking"
  location              = azurerm_resource_group.security.location
  resource_group_name   = azurerm_resource_group.security.name
  workspace_resource_id = azurerm_log_analytics_workspace.main.id
  workspace_name        = azurerm_log_analytics_workspace.main.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ChangeTracking"
  }

  tags = var.tags
}

resource "azurerm_log_analytics_solution" "vm_insights" {
  solution_name         = "VMInsights"
  location              = azurerm_resource_group.security.location
  resource_group_name   = azurerm_resource_group.security.name
  workspace_resource_id = azurerm_log_analytics_workspace.main.id
  workspace_name        = azurerm_log_analytics_workspace.main.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/VMInsights"
  }

  tags = var.tags
}

# Azure Security Center (Defender for Cloud) - Workspace configuration
resource "azurerm_security_center_workspace" "main" {
  count = var.enable_security_center ? 1 : 0

  scope        = data.azurerm_subscription.current.id
  workspace_id = azurerm_log_analytics_workspace.main.id
}

# Azure Security Center Contact
resource "azurerm_security_center_contact" "main" {
  count = var.enable_security_center && var.security_contact_email != "" ? 1 : 0

  email               = var.security_contact_email
  phone               = var.security_contact_phone
  alert_notifications = true
  alerts_to_admins    = true
}

# Azure Security Center Auto Provisioning
resource "azurerm_security_center_auto_provisioning" "main" {
  count = var.enable_security_center ? 1 : 0

  auto_provision = "On"
}

# Azure Defender Plans (Security Center Pricing)
resource "azurerm_security_center_subscription_pricing" "vm" {
  count = var.enable_security_center ? 1 : 0

  tier          = var.security_center_tier
  resource_type = "VirtualMachines"
}

resource "azurerm_security_center_subscription_pricing" "sql_servers" {
  count = var.enable_security_center ? 1 : 0

  tier          = var.security_center_tier
  resource_type = "SqlServers"
}

resource "azurerm_security_center_subscription_pricing" "app_services" {
  count = var.enable_security_center ? 1 : 0

  tier          = var.security_center_tier
  resource_type = "AppServices"
}

resource "azurerm_security_center_subscription_pricing" "storage_accounts" {
  count = var.enable_security_center ? 1 : 0

  tier          = var.security_center_tier
  resource_type = "StorageAccounts"
}

resource "azurerm_security_center_subscription_pricing" "containers" {
  count = var.enable_security_center ? 1 : 0

  tier          = var.security_center_tier
  resource_type = "Containers"
}

resource "azurerm_security_center_subscription_pricing" "key_vaults" {
  count = var.enable_security_center ? 1 : 0

  tier          = var.security_center_tier
  resource_type = "KeyVaults"
}

# Azure Monitor Action Group for alerts
resource "azurerm_monitor_action_group" "main" {
  name                = "ag-security-alerts"
  resource_group_name = azurerm_resource_group.security.name
  short_name          = "sekalerts"
  tags                = var.tags

  dynamic "email_receiver" {
    for_each = var.alert_email_receivers
    content {
      name                    = email_receiver.value.name
      email_address           = email_receiver.value.email_address
      use_common_alert_schema = true
    }
  }
}

# Activity Log Alerts
resource "azurerm_monitor_activity_log_alert" "create_policy_assignment" {
  name                = "alert-policy-assignment-created"
  resource_group_name = azurerm_resource_group.security.name
  scopes              = [data.azurerm_subscription.current.id]
  description         = "Alert when a policy assignment is created"
  tags                = var.tags

  criteria {
    category       = "Policy"
    operation_name = "Microsoft.Authorization/policyAssignments/write"
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}

resource "azurerm_monitor_activity_log_alert" "delete_resource_group" {
  name                = "alert-resource-group-deleted"
  resource_group_name = azurerm_resource_group.security.name
  scopes              = [data.azurerm_subscription.current.id]
  description         = "Alert when a resource group is deleted"
  tags                = var.tags

  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Resources/subscriptions/resourceGroups/delete"
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}

# Diagnostic Settings for Subscription
resource "azurerm_monitor_diagnostic_setting" "subscription" {
  name                       = "diag-subscription"
  target_resource_id         = data.azurerm_subscription.current.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "Administrative"
  }

  enabled_log {
    category = "Security"
  }

  enabled_log {
    category = "Policy"
  }

  enabled_log {
    category = "Alert"
  }
}
