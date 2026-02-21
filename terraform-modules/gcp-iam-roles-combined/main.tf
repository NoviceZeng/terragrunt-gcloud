# Combined IAM Roles Module
# Calls both VM and Storage submodules

module "vm_roles" {
  source = "../gcp-iam-roles/vm"
  
  project_id           = var.project_id
  vm_role_assignments = var.vm_role_assignments
}

module "storage_roles" {
  source = "../gcp-iam-roles/storage"
  
  project_id                = var.project_id
  storage_role_assignments = var.storage_role_assignments
}
