# GCP VMs Related IAM Roles
# Custom roles for Google Compute Engine (GCP VMs) management

# VM Viewer - Read-only access to VMs
resource "google_project_iam_custom_role" "vm_viewer" {
  role_id     = "vm-viewer"
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

# VM Operator - Start/stop and reboot VMs
resource "google_project_iam_custom_role" "vm_operator" {
  role_id     = "vm-operator"
  title       = "VM Operator"
  description = "Can start, stop, reboot, and view compute instances"
  
  permissions = [
    # View permissions
    "compute.instances.get",
    "compute.instances.list",
    "compute.instances.getSerialPortOutput",
    "compute.zones.get",
    "compute.zones.list",
    
    # Instance lifecycle
    "compute.instances.start",
    "compute.instances.stop",
    "compute.instances.reset",
  ]
  
  stage   = "GA"
  project = var.project_id
}

# VM Admin - Full control over VMs
resource "google_project_iam_custom_role" "vm_admin" {
  role_id     = "vm-admin"
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
  role_id     = "vm-developer"
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

# VM SSH Access - SSH into VMs only
resource "google_project_iam_custom_role" "vm_ssh" {
  role_id     = "vm-ssh"
  title       = "VM SSH Access"
  description = "SSH access to compute instances without modification permissions"
  
  permissions = [
    "compute.instances.get",
    "compute.instances.list",
    "compute.instances.getSerialPortOutput",
    "compute.instances.osLogin",
    "compute.zones.get",
    "compute.zones.list",
  ]
  
  stage   = "GA"
  project = var.project_id
}

# VM Snapshot Manager - Create and manage snapshots
resource "google_project_iam_custom_role" "vm_snapshot_manager" {
  role_id     = "vm-snapshot-manager"
  title       = "VM Snapshot Manager"
  description = "Create, delete, and manage disk snapshots for backup"
  
  permissions = [
    # View permissions
    "compute.disks.get",
    "compute.disks.list",
    "compute.zones.get",
    "compute.zones.list",
    
    # Snapshot operations
    "compute.snapshots.create",
    "compute.snapshots.delete",
    "compute.snapshots.get",
    "compute.snapshots.list",
    "compute.snapshots.useReadOnly",
    "compute.snapshots.setLabels",
  ]
  
  stage   = "GA"
  project = var.project_id
}

# Role assignments map for lookup
locals {
  vm_roles_map = {
    "vm-viewer"              = google_project_iam_custom_role.vm_viewer
    "vm-operator"            = google_project_iam_custom_role.vm_operator
    "vm-admin"               = google_project_iam_custom_role.vm_admin
    "vm-developer"           = google_project_iam_custom_role.vm_developer
    "vm-ssh"                 = google_project_iam_custom_role.vm_ssh
    "vm-snapshot-manager"    = google_project_iam_custom_role.vm_snapshot_manager
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
