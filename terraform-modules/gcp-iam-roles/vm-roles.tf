# GCP VMs Related IAM Roles
# Custom roles for Google Compute Engine (GCP VMs) management

# VM Viewer - Read-only access to VMs
resource "google_project_iam_custom_role" "vm_viewer" {
  role_id     = "vm_viewer"
  title       = "VM Viewer"
  description = "Read-only access to view compute instances and their details"
  
  permissions = [
    "compute.instances.get",
    "compute.instances.list",
    "compute.instances.getSerialPortOutput",
    "compute.machineTypes.get",
    "compute.machineTypes.list",
    "compute.zones.get",
    "compute.zones.list",
    "compute.regions.get",
    "compute.regions.list",
  ]
  
  stage   = "GA"
  project = var.project_id
}

# VM Admin - Full control over VMs
resource "google_project_iam_custom_role" "vm_admin" {
  role_id     = "vm_admin"
  title       = "VM Admin"
  description = "Full administrative access to compute instances"
  
  permissions = [
    # View permissions
    "compute.instances.get",
    "compute.instances.list",
    "compute.instances.getSerialPortOutput",
    "compute.machineTypes.get",
    "compute.machineTypes.list",
    "compute.zones.get",
    "compute.zones.list",
    "compute.disks.get",
    "compute.disks.list",
    "compute.networks.get",
    "compute.networks.list",
    "compute.subnetworks.get",
    "compute.subnetworks.list",
    
    # Instance lifecycle
    "compute.instances.create",
    "compute.instances.delete",
    "compute.instances.start",
    "compute.instances.stop",
    "compute.instances.reset",
    "compute.instances.setMachineType",
    "compute.instances.updateNetworkInterface",
    
    # Instance configuration
    "compute.instances.setMetadata",
    "compute.instances.setTags",
    "compute.instances.setServiceAccount",
    "compute.instances.setLabels",
    "compute.instances.osLogin",
    "compute.instances.setIamPolicy",
    "compute.instances.getIamPolicy",
    
    # Disk management
    "compute.disks.create",
    "compute.disks.delete",
    "compute.disks.update",
    "compute.disks.use",
    "compute.disks.useReadOnly",
    
    # Network operations
    "compute.subnetworks.use",
    "compute.subnetworks.useExternalIp",
    "compute.addresses.use",
  ]
  
  stage   = "GA"
  project = var.project_id
}

# VM Developer - Create and manage development VMs
resource "google_project_iam_custom_role" "vm_developer" {
  role_id     = "vm_developer"
  title       = "VM Developer"
  description = "Developer access to create, modify, and SSH into VMs"
  
  permissions = [
    # View permissions
    "compute.instances.get",
    "compute.instances.list",
    "compute.instances.getSerialPortOutput",
    "compute.zones.get",
    "compute.zones.list",
    "compute.disks.get",
    "compute.disks.list",
    "compute.networks.get",
    "compute.subnetworks.get",
    
    # Instance lifecycle
    "compute.instances.create",
    "compute.instances.delete",
    "compute.instances.start",
    "compute.instances.stop",
    "compute.instances.reset",
    
    # Instance configuration
    "compute.instances.setMetadata",
    "compute.instances.setTags",
    "compute.instances.osLogin",
    "compute.instances.setIamPolicy",
    
    # Disk operations
    "compute.disks.create",
    "compute.disks.delete",
    "compute.disks.use",
    
    # Network operations
    "compute.subnetworks.use",
  ]
  
  stage   = "GA"
  project = var.project_id
}

# Role assignments map for lookup
locals {
  vm_roles_map = {
    "vm_viewer"    = google_project_iam_custom_role.vm_viewer
    "vm_admin"     = google_project_iam_custom_role.vm_admin
    "vm_developer" = google_project_iam_custom_role.vm_developer
  }
}

# Assign VM roles to members (users and groups)
resource "google_project_iam_member" "vm_members" {
  count = length(var.vm_role_assignments.members)
  
  project = var.project_id
  role    = local.vm_roles_map[var.vm_role_assignments.role_id].name
  member  = var.vm_role_assignments.members[count.index]
}

# Assign VM roles to service accounts
resource "google_project_iam_member" "vm_service_accounts" {
  count = length(var.vm_role_assignments.service_account_emails)
  
  project = var.project_id
  role    = local.vm_roles_map[var.vm_role_assignments.role_id].name
  member  = "serviceAccount:${var.vm_role_assignments.service_account_emails[count.index]}"
}
