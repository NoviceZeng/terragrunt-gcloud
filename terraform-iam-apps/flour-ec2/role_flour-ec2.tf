# Define a reusable custom IAM role (project-scoped)
resource "google_iam_custom_role" "my_custom_viewer" {
  role_id     = var.role_id
  title       = "My Custom Viewer Role"
  description = "Custom role with specific viewing permissions"
  permissions = [
    "compute.instances.get",
    "compute.instances.list",
    "storage.buckets.get",
    "storage.buckets.list",
  ]
  stage   = "GA"
  project = var.project_id
}

# Assign the role to a set of members (e.g. users, groups)
resource "google_project_iam_member" "custom_role_assignment" {
  for_each = toset(var.members)

  project = var.project_id
  role    = google_iam_custom_role.my_custom_viewer.name
  member  = each.value
}

# Assign a predefined role (default: roles/viewer) to one or more service account emails
resource "google_project_iam_member" "service_account_predefined" {
  for_each = toset(var.service_account_emails)

  project = var.project_id
  role    = "roles/viewer"
  member  = "serviceAccount:${each.value}"
}
