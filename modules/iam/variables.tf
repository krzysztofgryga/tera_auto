variable "management_group_id" {
  description = "ID of the management group for RBAC assignments"
  type        = string
}

variable "organization_name" {
  description = "Name of the organization"
  type        = string
  default     = ""
}

variable "rbac_assignments" {
  description = "RBAC role assignments"
  type = map(object({
    role_definition_name        = string
    principal_id                = string
    skip_service_principal_check = optional(bool, false)
  }))
  default = {}
}

variable "create_ad_groups" {
  description = "Create Azure AD groups for the landing zone"
  type        = bool
  default     = false
}
