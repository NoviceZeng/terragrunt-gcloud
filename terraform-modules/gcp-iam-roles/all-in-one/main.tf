# All-in-One IAM Roles Module
# Manages all roles together in a single deployment

module "vm_roles" {
  source = "../vm"
  
  project_id           = var.project_id
  vm_role_assignments = var.vm_role_assignments
}

# module "storage_roles" {
#   source = "../storage"
  
#   project_id                = var.project_id
#   storage_role_assignments = var.storage_role_assignments
# }
