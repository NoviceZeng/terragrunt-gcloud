resource "google_project_iam_custom_role" "gcs_editor" {
  role_id     = var.role_id
  project     = var.project_id
  title       = var.title
  description = "Custom role granting GCS edit permissions"
  permissions = var.permissions
  stage       = "GA"
}

resource "google_project_iam_member" "members" {
  for_each = toset(var.members)

  project = var.project_id
  role    = google_project_iam_custom_role.gcs_editor.name
  member  = each.value
}

resource "google_project_iam_member" "service_accounts" {
  for_each = toset(var.service_account_emails)

  project = var.project_id
  role    = google_project_iam_custom_role.gcs_editor.name
  member  = "serviceAccount:${each.value}"
}