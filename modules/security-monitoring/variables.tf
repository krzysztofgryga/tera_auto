variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "log_analytics_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 30
}

variable "enable_security_center" {
  description = "Enable Azure Security Center"
  type        = bool
  default     = true
}

variable "security_center_tier" {
  description = "Security Center pricing tier"
  type        = string
  default     = "Standard"
}

variable "security_contact_email" {
  description = "Email address for security contact"
  type        = string
  default     = ""
}

variable "security_contact_phone" {
  description = "Phone number for security contact"
  type        = string
  default     = ""
}

variable "alert_email_receivers" {
  description = "Email receivers for alerts"
  type = list(object({
    name          = string
    email_address = string
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
