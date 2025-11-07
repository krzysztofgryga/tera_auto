output "resource_group_id" {
  description = "ID of the shared services resource group"
  value       = azurerm_resource_group.shared_services.id
}

output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.main.id
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.main.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

output "storage_account_id" {
  description = "ID of the shared storage account"
  value       = azurerm_storage_account.shared.id
}

output "storage_account_name" {
  description = "Name of the shared storage account"
  value       = azurerm_storage_account.shared.name
}

output "storage_account_primary_blob_endpoint" {
  description = "Primary blob endpoint of the storage account"
  value       = azurerm_storage_account.shared.primary_blob_endpoint
}

output "automation_account_id" {
  description = "ID of the Automation Account"
  value       = var.create_automation_account ? azurerm_automation_account.main[0].id : null
}

output "recovery_vault_id" {
  description = "ID of the Recovery Services Vault"
  value       = var.create_recovery_vault ? azurerm_recovery_services_vault.main[0].id : null
}

output "backup_policy_id" {
  description = "ID of the backup policy"
  value       = var.create_recovery_vault ? azurerm_backup_policy_vm.daily[0].id : null
}
