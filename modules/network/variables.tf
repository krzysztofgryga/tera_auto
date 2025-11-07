variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "hub_vnet_config" {
  description = "Configuration for hub virtual network"
  type = object({
    name          = string
    address_space = list(string)
    subnets = map(object({
      address_prefix    = string
      service_endpoints = optional(list(string), [])
    }))
  })
}

variable "spoke_vnets" {
  description = "Configuration for spoke virtual networks"
  type = map(object({
    name          = string
    address_space = list(string)
    subnets = map(object({
      address_prefix    = string
      service_endpoints = optional(list(string), [])
    }))
  }))
}

variable "enable_ddos_protection" {
  description = "Enable DDoS Protection Plan"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
