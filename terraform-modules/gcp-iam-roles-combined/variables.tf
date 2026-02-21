variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "vm_role_assignments" {
  description = "VM role assignments for members and service accounts"
  type = object({
    role_id                 = string
    members                 = list(string)
    service_account_emails  = list(string)
  })
}

variable "storage_role_assignments" {
  description = "Storage role assignments for members and service accounts"
  type = object({
    role_id                 = string
    members                 = list(string)
    service_account_emails  = list(string)
  })
}
