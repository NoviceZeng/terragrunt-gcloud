variable "project_id" {
  type        = string
  description = "GCP project id where the role will be created"
}

variable "role_id" {
  type        = string
  description = "Custom role id"
  default     = "my_custom_viewer"
}

variable "members" {
  type        = list(string)
  description = "List of IAM members to bind the custom role to (e.g. user:ops@example.com)"
  default     = []
}

variable "service_account_emails" {
  type        = list(string)
  description = "List of service account emails to assign the predefined role to"
  default     = []
}
