variable "project_id" {
  type = string
}

variable "vms" {
  type = list(object({
    name               = string
    hostname           = optional(string)
    ip                 = optional(string)
    machine_type       = string
    disk               = optional(string)
    zone               = string
    region             = optional(string)
    bootdisksize       = optional(number)
    bootimage          = optional(string)
    subnetname         = optional(string)
    tags               = optional(list(string), [])
    enable_external_ip = optional(bool, true)
  }))
  default = []
}

# Firewall variables
variable "enable_firewall_rules" {
  description = "Enable creation of firewall rules"
  type        = bool
  default     = true
}

variable "network" {
  description = "VPC network name for firewall rules"
  type        = string
  default     = "default"
}

variable "firewall_name_prefix" {
  description = "Prefix for firewall rule names"
  type        = string
  default     = "vm"
}

variable "ssh_source_ranges" {
  description = "Source IP ranges allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Change to your office IP for better security
}

variable "internal_source_ranges" {
  description = "Internal IP ranges for inter-VM communication"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

# Service Account variables
variable "create_service_account" {
  description = "Create a service account for VMs"
  type        = bool
  default     = true
}

variable "service_account_prefix" {
  description = "Prefix for service account name"
  type        = string
  default     = "vm"
}

variable "service_account_email" {
  description = "Existing service account email to use (if not creating new one)"
  type        = string
  default     = null
}

variable "service_account_scopes" {
  description = "Service account scopes for VMs"
  type        = list(string)
  default = [
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
  ]
}
