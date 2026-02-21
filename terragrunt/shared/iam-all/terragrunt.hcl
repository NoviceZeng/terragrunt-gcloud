# Include root configuration
include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

# Use both VM and Storage IAM modules together
terraform {
  source = "../../../terraform-modules/gcp-iam-roles/all-in-one"
}

# All IAM role assignments in one place
inputs = {
  # VM role assignments
  vm_role_assignments = {
    role_id = "vm-admin"
    
    members = [
      "user:cloud-ops@example.com",
      "group:platform-team@example.com",
    ]
    
    service_account_emails = [
      "vm-automation@acme-gcp-prod-12345.iam.gserviceaccount.com",
    ]
  }
  
  # Storage role assignments
  storage_role_assignments = {
    role_id = "storage-data-pipeline"
    
    members = [
      "user:data-engineer@example.com",
      "group:data-team@example.com",
    ]
    
    service_account_emails = [
      "etl-job@acme-gcp-prod-12345.iam.gserviceaccount.com",
    ]
  }
}
