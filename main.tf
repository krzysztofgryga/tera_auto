terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.45"
    }
  }

  # Uncomment for remote state
  # backend "azurerm" {
  #   resource_group_name  = "rg-terraform-state"
  #   storage_account_name = "sttfstate"
  #   container_name       = "tfstate"
  #   key                  = "landing-zone.tfstate"
  # }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

provider "azuread" {}

# Management Groups
module "management_groups" {
  source = "./modules/management-groups"

  root_management_group_name = var.root_management_group_name
  organization_name          = var.organization_name
}

# Network Infrastructure (Hub-Spoke)
module "network" {
  source = "./modules/network"

  location            = var.location
  resource_group_name = var.network_resource_group_name
  hub_vnet_config     = var.hub_vnet_config
  spoke_vnets         = var.spoke_vnets
  tags                = var.tags

  depends_on = [module.management_groups]
}

# Azure Policy and Governance
module "policy" {
  source = "./modules/policy"

  management_group_id = module.management_groups.root_management_group_id
  location            = var.location
  tags                = var.tags

  depends_on = [module.management_groups]
}

# Security and Monitoring
module "security_monitoring" {
  source = "./modules/security-monitoring"

  location                    = var.location
  resource_group_name         = var.security_resource_group_name
  log_analytics_retention_days = var.log_analytics_retention_days
  enable_security_center      = var.enable_security_center
  security_center_tier        = var.security_center_tier
  tags                        = var.tags

  depends_on = [module.management_groups]
}

# Identity and Access Management
module "iam" {
  source = "./modules/iam"

  management_group_id = module.management_groups.root_management_group_id
  organization_name   = var.organization_name
  rbac_assignments    = var.rbac_assignments

  depends_on = [module.management_groups]
}

# Shared Services
module "shared_services" {
  source = "./modules/shared-services"

  location            = var.location
  resource_group_name = var.shared_services_resource_group_name
  key_vault_config    = var.key_vault_config
  tags                = var.tags

  depends_on = [module.network]
}
