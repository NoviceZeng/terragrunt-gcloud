inputs = {
  project_id             = "prod-project-id"
  role_id                = "my_custom_viewer"
  members                = ["user:prod-ops@example.com"]
  service_account_emails = ["prod-sa@prod-project-id.iam.gserviceaccount.com"]
}
