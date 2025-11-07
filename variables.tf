variable "organization_name" {
  description = "Name of the organization for naming conventions"
  type        = string
}

variable "root_management_group_name" {
  description = "Name of the root management group"
  type        = string
  default     = "Root"
}

variable "location" {
  description = "Primary Azure region for resources"
  type        = string
  default     = "westeurope"
}

variable "network_resource_group_name" {
  description = "Name of the resource group for network resources"
  type        = string
  default     = "rg-network-hub"
}

variable "security_resource_group_name" {
  description = "Name of the resource group for security resources"
  type        = string
  default     = "rg-security"
}

variable "shared_services_resource_group_name" {
  description = "Name of the resource group for shared services"
  type        = string
  default     = "rg-shared-services"
}

variable "hub_vnet_config" {
  description = "Configuration for hub virtual network"
  type = object({
    name          = string
    address_space = list(string)
    subnets = map(object({
      address_prefix = string
      service_endpoints = optional(list(string), [])
    }))
  })
  default = {
    name          = "vnet-hub"
    address_space = ["10.0.0.0/16"]
    subnets = {
      AzureFirewallSubnet = {
        address_prefix = "10.0.1.0/24"
      }
      GatewaySubnet = {
        address_prefix = "10.0.2.0/24"
      }
      AzureBastionSubnet = {
        address_prefix = "10.0.3.0/24"
      }
      SharedServices = {
        address_prefix = "10.0.4.0/24"
      }
    }
  }
}

variable "spoke_vnets" {
  description = "Configuration for spoke virtual networks"
  type = map(object({
    name          = string
    address_space = list(string)
    subnets = map(object({
      address_prefix = string
      service_endpoints = optional(list(string), [])
    }))
  }))
  default = {
    production = {
      name          = "vnet-spoke-prod"
      address_space = ["10.1.0.0/16"]
      subnets = {
        web = {
          address_prefix = "10.1.1.0/24"
        }
        app = {
          address_prefix = "10.1.2.0/24"
        }
        data = {
          address_prefix = "10.1.3.0/24"
        }
      }
    }
    development = {
      name          = "vnet-spoke-dev"
      address_space = ["10.2.0.0/16"]
      subnets = {
        web = {
          address_prefix = "10.2.1.0/24"
        }
        app = {
          address_prefix = "10.2.2.0/24"
        }
        data = {
          address_prefix = "10.2.3.0/24"
        }
      }
    }
  }
}

variable "log_analytics_retention_days" {
  description = "Number of days to retain logs in Log Analytics"
  type        = number
  default     = 30
}

variable "enable_security_center" {
  description = "Enable Azure Security Center"
  type        = bool
  default     = true
}

variable "security_center_tier" {
  description = "Azure Security Center pricing tier"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Free", "Standard"], var.security_center_tier)
    error_message = "Security Center tier must be Free or Standard."
  }
}

variable "key_vault_config" {
  description = "Configuration for Key Vault"
  type = object({
    name                       = string
    sku_name                   = optional(string, "standard")
    soft_delete_retention_days = optional(number, 90)
    purge_protection_enabled   = optional(bool, true)
  })
  default = {
    name     = "kv-shared-services"
    sku_name = "standard"
  }
}

variable "rbac_assignments" {
  description = "RBAC role assignments"
  type = map(object({
    role_definition_name = string
    principal_id         = string
  }))
  default = {}
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    Project     = "Landing-Zone"
  }
}
