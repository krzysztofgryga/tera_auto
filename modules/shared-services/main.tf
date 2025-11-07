data "azurerm_client_config" "current" {}

# Resource Group for Shared Services
resource "azurerm_resource_group" "shared_services" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Key Vault
resource "azurerm_key_vault" "main" {
  name                        = var.key_vault_config.name
  location                    = azurerm_resource_group.shared_services.location
  resource_group_name         = azurerm_resource_group.shared_services.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = var.key_vault_config.soft_delete_retention_days
  purge_protection_enabled    = var.key_vault_config.purge_protection_enabled
  sku_name                    = var.key_vault_config.sku_name

  enable_rbac_authorization = true

  network_acls {
    bypass         = "AzureServices"
    default_action = var.key_vault_network_acls.default_action
    ip_rules       = var.key_vault_network_acls.ip_rules
    virtual_network_subnet_ids = var.key_vault_network_acls.virtual_network_subnet_ids
  }

  tags = var.tags
}

# Key Vault Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "key_vault" {
  count = var.log_analytics_workspace_id != "" ? 1 : 0

  name                       = "diag-keyvault"
  target_resource_id         = azurerm_key_vault.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AuditEvent"
  }

  metric {
    category = "AllMetrics"
  }
}

# Storage Account for Shared Services
resource "azurerm_storage_account" "shared" {
  name                     = replace(lower("st${var.resource_group_name}"), "-", "")
  resource_group_name      = azurerm_resource_group.shared_services.name
  location                 = azurerm_resource_group.shared_services.location
  account_tier             = "Standard"
  account_replication_type = var.storage_replication_type
  account_kind             = "StorageV2"
  min_tls_version          = "TLS1_2"

  enable_https_traffic_only = true

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 30
    }

    container_delete_retention_policy {
      days = 30
    }
  }

  network_rules {
    default_action             = var.storage_network_rules.default_action
    bypass                     = ["AzureServices"]
    ip_rules                   = var.storage_network_rules.ip_rules
    virtual_network_subnet_ids = var.storage_network_rules.virtual_network_subnet_ids
  }

  tags = var.tags
}

# Storage Account Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "storage" {
  count = var.log_analytics_workspace_id != "" ? 1 : 0

  name                       = "diag-storage"
  target_resource_id         = "${azurerm_storage_account.shared.id}/blobServices/default/"
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }

  metric {
    category = "Transaction"
  }
}

# Container for Terraform State (optional)
resource "azurerm_storage_container" "terraform_state" {
  count = var.create_terraform_state_container ? 1 : 0

  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.shared.name
  container_access_type = "private"
}

# Container for Flow Logs
resource "azurerm_storage_container" "flow_logs" {
  name                  = "network-flow-logs"
  storage_account_name  = azurerm_storage_account.shared.name
  container_access_type = "private"
}

# Container for Boot Diagnostics
resource "azurerm_storage_container" "boot_diagnostics" {
  name                  = "boot-diagnostics"
  storage_account_name  = azurerm_storage_account.shared.name
  container_access_type = "private"
}

# Automation Account (for runbooks, update management)
resource "azurerm_automation_account" "main" {
  count = var.create_automation_account ? 1 : 0

  name                = "aa-${var.resource_group_name}"
  location            = azurerm_resource_group.shared_services.location
  resource_group_name = azurerm_resource_group.shared_services.name
  sku_name            = "Basic"

  tags = var.tags
}

# Link Automation Account to Log Analytics
resource "azurerm_log_analytics_linked_service" "automation" {
  count = var.create_automation_account && var.log_analytics_workspace_id != "" ? 1 : 0

  resource_group_name = var.log_analytics_resource_group_name
  workspace_id        = var.log_analytics_workspace_id
  read_access_id      = azurerm_automation_account.main[0].id
}

# Recovery Services Vault (for backups)
resource "azurerm_recovery_services_vault" "main" {
  count = var.create_recovery_vault ? 1 : 0

  name                = "rsv-${var.resource_group_name}"
  location            = azurerm_resource_group.shared_services.location
  resource_group_name = azurerm_resource_group.shared_services.name
  sku                 = "Standard"
  soft_delete_enabled = true

  tags = var.tags
}

# Backup Policy
resource "azurerm_backup_policy_vm" "daily" {
  count = var.create_recovery_vault ? 1 : 0

  name                = "backup-policy-daily"
  resource_group_name = azurerm_resource_group.shared_services.name
  recovery_vault_name = azurerm_recovery_services_vault.main[0].name

  timezone = "UTC"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 30
  }

  retention_weekly {
    count    = 12
    weekdays = ["Sunday"]
  }

  retention_monthly {
    count    = 12
    weekdays = ["Sunday"]
    weeks    = ["First"]
  }
}
