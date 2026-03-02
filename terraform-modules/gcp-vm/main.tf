provider "google" {
  project = var.project_id
}

resource "google_compute_instance" "vm" {
  for_each = { for v in var.vms : v.name => v }

  name         = each.value.name
  zone         = each.value.zone
  machine_type = each.value.machine_type

  boot_disk {
    initialize_params {
      image = lookup(each.value, "bootimage", null)
      size  = lookup(each.value, "bootdisksize", 0)
      type  = lookup(each.value, "disk", null)
    }
  }

  network_interface {
    subnetwork = lookup(each.value, "subnetname", null)
    network_ip = lookup(each.value, "ip", null)
    
    # Only add external IP if enabled
    dynamic "access_config" {
      for_each = lookup(each.value, "enable_external_ip", false) ? [1] : []
      content {}
    }
  }

  metadata = {
    hostname = lookup(each.value, "hostname", "")
  }

  # Assign service account if created
  service_account {
    email  = var.create_service_account ? google_service_account.vm_sa[0].email : var.service_account_email
    scopes = var.service_account_scopes
  }

  tags = concat(
    lookup(each.value, "tags", []),
    ["ssh-allowed", "internal"]  # Add default security tags
  )

  # Enable shielded VM features for security
  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }
}
