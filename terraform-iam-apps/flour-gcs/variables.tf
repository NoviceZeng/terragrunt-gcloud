variable "project_id" {
  type = string
}

variable "role_id" {
  type    = string
  default = "gcs_editor_role"
}

variable "title" {
  type    = string
  default = "GCS Editor Custom Role"
}

variable "permissions" {
  type = list(string)
  default = [
    "storage.buckets.get",
    "storage.buckets.list",
    "storage.objects.get",
    "storage.objects.list",
    "storage.objects.create",
    "storage.objects.delete",
    "storage.objects.update",
    "storage.objects.copy"
  ]
}

variable "members" {
  type    = list(string)
  default = []
}

variable "service_account_emails" {
  type    = list(string)
  default = []
}