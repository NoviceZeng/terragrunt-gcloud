output "custom_role_name" {
  description = "The full name of the created custom role"
  value       = google_iam_custom_role.my_custom_viewer.name
}

output "custom_role_id" {
  description = "The role id of the created custom role"
  value       = google_iam_custom_role.my_custom_viewer.role_id
}
