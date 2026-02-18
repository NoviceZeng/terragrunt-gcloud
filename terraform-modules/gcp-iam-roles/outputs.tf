output "custom_roles" {
  description = "Created custom IAM roles"
  value = {
    for role_key, role in google_project_iam_custom_role.custom_role :
    role_key => {
      name = role.name
      id   = role.id
    }
  }
}

output "role_assignments" {
  description = "Summary of role assignments"
  value = {
    members          = [for m in google_project_iam_member.members : m.member]
    service_accounts = [for sa in google_project_iam_member.service_accounts : sa.member]
  }
}
