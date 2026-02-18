output "custom_role_name" {
  value = google_project_iam_custom_role.gcs_editor.name
}

output "custom_role_id" {
  value = google_project_iam_custom_role.gcs_editor.role_id
}