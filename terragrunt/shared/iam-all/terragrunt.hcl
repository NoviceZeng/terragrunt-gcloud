# Include root configuration
include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

# Use both VM and Storage IAM modules together
terraform {
  source = "../../../terraform-modules/gcp-iam-roles"
}

# All IAM role assignments in one place
inputs = {
  # Project ID for this deployment
  project_id = "project-novice-486516"

  # VM role assignments
  vm_role_assignments = {
    role_id = "vm_admin"
    
    members = [
      "user:novice.tseng@gmail.com",
      #"group:platform-team@example.com",
    ]
    
    service_account_emails = [
      "vm-automation@project-novice-486516.iam.gserviceaccount.com",
    ]
  }
  
  # Storage role assignments
  storage_role_assignments = {
    role_id = "storage_data_pipeline"
    
    members = [
      "user:data-engineer@example.com",
      "group:data-team@example.com",
    ]
    
    service_account_emails = [
      "etl-job@project-novice-486516.iam.gserviceaccount.com",
    ]
  }
}
