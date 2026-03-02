# GCP Cloud Storage (GCS) Related IAM Roles
# Custom roles for Google Cloud Storage bucket and object management

# Storage Viewer - Read-only access to buckets and objects
resource "google_project_iam_custom_role" "storage_viewer" {
  role_id     = "storage_viewer"
  title       = "Storage Viewer"
  description = "Read-only access to view Cloud Storage buckets and objects"
  
  permissions = [
    "storage.buckets.get",
    "storage.buckets.list",
    "storage.buckets.getIamPolicy",
    "storage.objects.get",
    "storage.objects.list",
  ]
  
  stage   = "GA"
  project = var.project_id
}

# Storage Editor - Read and write access to buckets and objects
resource "google_project_iam_custom_role" "storage_editor" {
  role_id     = "storage_editor"
  title       = "Storage Editor"
  description = "Read and write access to Cloud Storage buckets and objects"
  
  permissions = [
    # View permissions
    "storage.buckets.get",
    "storage.buckets.list",
    "storage.buckets.getIamPolicy",
    
    # Object permissions
    "storage.objects.get",
    "storage.objects.list",
    "storage.objects.create",
    "storage.objects.delete",
    "storage.objects.update",
  ]
  
  stage   = "GA"
  project = var.project_id
}

# Storage Admin - Full control over buckets and objects
resource "google_project_iam_custom_role" "storage_admin" {
  role_id     = "storage_admin"
  title       = "Storage Admin"
  description = "Full administrative access to Cloud Storage buckets and objects"
  
  permissions = [
    # Bucket permissions
    "storage.buckets.get",
    "storage.buckets.list",
    "storage.buckets.create",
    "storage.buckets.delete",
    "storage.buckets.update",
    "storage.buckets.getIamPolicy",
    "storage.buckets.setIamPolicy",
    
    # Object permissions
    "storage.objects.get",
    "storage.objects.list",
    "storage.objects.create",
    "storage.objects.delete",
    "storage.objects.update",
    "storage.objects.getIamPolicy",
    "storage.objects.setIamPolicy",
  ]
  
  stage   = "GA"
  project = var.project_id
}

# Storage Data Pipeline - Read/write for ETL and data processing
resource "google_project_iam_custom_role" "storage_data_pipeline" {
  role_id     = "storage_data_pipeline"
  title       = "Storage Data Pipeline"
  description = "Read and write access for ETL and data processing pipelines"
  
  permissions = [
    # Bucket view
    "storage.buckets.get",
    "storage.buckets.list",
    
    # Object read/write permissions
    "storage.objects.get",
    "storage.objects.list",
    "storage.objects.create",
    "storage.objects.update",
    "storage.objects.delete",
  ]
  
  stage   = "GA"
  project = var.project_id
}

# Role assignments map for lookup
locals {
  storage_roles_map = {
    "storage_viewer"        = google_project_iam_custom_role.storage_viewer
    "storage_editor"        = google_project_iam_custom_role.storage_editor
    "storage_admin"         = google_project_iam_custom_role.storage_admin
    "storage_data_pipeline" = google_project_iam_custom_role.storage_data_pipeline
  }
}

# Assign storage roles to members (users and groups)
resource "google_project_iam_member" "storage_members" {
  count = length(var.storage_role_assignments.members)
  
  project = var.project_id
  role    = local.storage_roles_map[var.storage_role_assignments.role_id].name
  member  = var.storage_role_assignments.members[count.index]
}

# Assign storage roles to service accounts
resource "google_project_iam_member" "storage_service_accounts" {
  count = length(var.storage_role_assignments.service_account_emails)

  depends_on = [
    google_service_account.etl_job
  ]
  
  project = var.project_id
  role    = local.storage_roles_map[var.storage_role_assignments.role_id].name
  member  = "serviceAccount:${var.storage_role_assignments.service_account_emails[count.index]}"
}
