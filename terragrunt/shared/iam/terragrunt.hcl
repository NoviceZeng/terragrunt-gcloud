# Include root configuration
include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

# Use the IAM roles module
# The module defines what roles exist and their permissions
# We only control WHO gets assigned to each role
terraform {
  source = "../../../terraform-modules/gcp-iam-roles"
}

# Role assignments - THIS is what Terragrunt should manage
# Technical role definitions are in the Terraform module
inputs = {
  project_id = "acme-gcp-prod-12345"  # Environment-specific
  
  # VM-specific role assignments managed by Terragrunt
  vm_role_assignments = {
    # Which role to assign
    role_id = "vm-operator"
    
    # Team members who get VM Operator role
    members = [
      "user:cloud-ops@example.com",
      "user:devops-lead@example.com",
      "group:cloud-operations@example.com",
      "group:platform-team@example.com",
    ]
    
    # Service accounts that get VM Operator role
    service_account_emails = [
      "vm-automation@acme-gcp-prod-12345.iam.gserviceaccount.com",
      "monitoring-bot@acme-gcp-prod-12345.iam.gserviceaccount.com",
    ]
  }
}

