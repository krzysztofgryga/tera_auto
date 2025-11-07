variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "key_vault_config" {
  description = "Configuration for Key Vault"
  type = object({
    name                       = string
    sku_name                   = optional(string, "standard")
    soft_delete_retention_days = optional(number, 90)
    purge_protection_enabled   = optional(bool, true)
  })
}

variable "key_vault_network_acls" {
  description = "Network ACLs for Key Vault"
  type = object({
    default_action             = optional(string, "Deny")
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default = {
    default_action = "Deny"
  }
}

variable "storage_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "GRS"
}

variable "storage_network_rules" {
  description = "Network rules for storage account"
  type = object({
    default_action             = optional(string, "Deny")
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default = {
    default_action = "Deny"
  }
}

variable "create_terraform_state_container" {
  description = "Create container for Terraform state"
  type        = bool
  default     = true
}

variable "create_automation_account" {
  description = "Create Automation Account"
  type        = bool
  default     = true
}

variable "create_recovery_vault" {
  description = "Create Recovery Services Vault"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "ID of Log Analytics workspace for diagnostics"
  type        = string
  default     = ""
}

variable "log_analytics_resource_group_name" {
  description = "Resource group name of Log Analytics workspace"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
