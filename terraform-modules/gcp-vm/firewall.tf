# Firewall Rules for VMs

# Allow SSH from specific IP ranges
resource "google_compute_firewall" "allow_ssh" {
  count = var.enable_firewall_rules ? 1 : 0
  
  name    = "${var.firewall_name_prefix}-allow-ssh"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.ssh_source_ranges
  target_tags   = ["ssh-allowed"]
}

# Allow HTTP/HTTPS for web servers
resource "google_compute_firewall" "allow_http_https" {
  count = var.enable_firewall_rules ? 1 : 0
  
  name    = "${var.firewall_name_prefix}-allow-http-https"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]  # Public access
  target_tags   = ["http-server", "https-server"]
}

# Allow internal communication between VMs
resource "google_compute_firewall" "allow_internal" {
  count = var.enable_firewall_rules ? 1 : 0
  
  name    = "${var.firewall_name_prefix}-allow-internal"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = var.internal_source_ranges
  target_tags   = ["internal"]
}

# Allow database access from app servers only
resource "google_compute_firewall" "allow_db_from_app" {
  count = var.enable_firewall_rules ? 1 : 0
  
  name    = "${var.firewall_name_prefix}-allow-db-from-app"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["3306", "5432", "27017"]  # MySQL, PostgreSQL, MongoDB
  }

  source_tags = ["app"]
  target_tags = ["database"]
}

# Service Account for VMs
resource "google_service_account" "vm_sa" {
  count = var.create_service_account ? 1 : 0
  
  account_id   = "${var.service_account_prefix}-vm-sa"
  display_name = "Service Account for VMs"
  description  = "Service account used by compute instances"
}

# IAM roles for service account (minimal permissions)
resource "google_project_iam_member" "vm_sa_log_writer" {
  count = var.create_service_account ? 1 : 0
  
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.vm_sa[0].email}"
}

resource "google_project_iam_member" "vm_sa_metric_writer" {
  count = var.create_service_account ? 1 : 0
  
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.vm_sa[0].email}"
}
