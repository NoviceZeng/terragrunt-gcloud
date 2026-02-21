variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "storage_role_assignments" {
  description = "Storage role assignments for members and service accounts"
  type = object({
    role_id                 = string
    members                 = list(string)
    service_account_emails  = list(string)
  })
  default = {
    role_id                = "storage-viewer"
    members                = []
    service_account_emails = []
  }
}
