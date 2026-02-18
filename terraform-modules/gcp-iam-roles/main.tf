provider "google" {
  project = var.project_id
}

# Create custom IAM roles
resource "google_project_iam_custom_role" "custom_role" {
  for_each = var.roles

  role_id     = each.value.role_id
  title       = each.value.title
  description = each.value.description
  permissions = each.value.permissions
  stage       = "GA"
  project     = var.project_id
}

# Assign roles to members (users and groups)
resource "google_project_iam_member" "members" {
  for_each = merge([
    for role_key, role_data in var.roles : {
      for member in role_data.members :
      "${role_key}-member-${member}" => {
        role_name = role_key
        member    = member
      }
    }
  ]...)

  project = var.project_id
  role    = google_project_iam_custom_role.custom_role[each.value.role_name].name
  member  = each.value.member
}

# Assign roles to service accounts
resource "google_project_iam_member" "service_accounts" {
  for_each = merge([
    for role_key, role_data in var.roles : {
      for sa_email in role_data.service_account_emails :
      "${role_key}-sa-${sa_email}" => {
        role_name = role_key
        member    = "serviceAccount:${sa_email}"
      }
    }
  ]...)

  project = var.project_id
  role    = google_project_iam_custom_role.custom_role[each.value.role_name].name
  member  = each.value.member
}
