variable "management_group_id" {
  description = "ID of the management group to apply policies to"
  type        = string
}

variable "location" {
  description = "Azure region for policy assignments with managed identities"
  type        = string
}

variable "allowed_locations" {
  description = "List of allowed Azure regions"
  type        = list(string)
  default = [
    "westeurope",
    "northeurope",
    "eastus",
    "westus"
  ]
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
