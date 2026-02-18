inputs = {
  project_id = "prod-project-id"

  roles = [
    {
      role_id                = "my_custom_editor"
      members                = ["user:prod-editor@example.com"]
      service_account_emails = ["prod-editor-sa@prod-project-id.iam.gserviceaccount.com"]
    },
    {
      role_id                = "my_custom_auditor"
      members                = ["user:prod-auditor@example.com"]
      service_account_emails = ["prod-auditor-sa@prod-project-id.iam.gserviceaccount.com"]
    }
  ]
}
