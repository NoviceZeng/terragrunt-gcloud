variable "project_id" {
  type        = string
  description = "GCP project ID where roles will be created"
}

variable "roles" {
  type = map(object({
    role_id     = string
    title       = string
    description = string
    permissions = list(string)
    members     = optional(list(string), [])
    service_account_emails = optional(list(string), [])
  }))
  description = "Map of custom IAM roles to create"
  
  validation {
    condition     = alltrue([for role in var.roles : role.role_id != ""])
    error_message = "Each role must have a non-empty role_id."
  }
  
  validation {
    condition     = alltrue([for role in var.roles : length(role.permissions) > 0])
    error_message = "Each role must have at least one permission."
  }
}
