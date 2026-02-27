# Service Accounts
# Create VM automation service account used by IAM bindings

resource "google_service_account" "vm_automation" {
  project      = var.project_id
  account_id   = "vm-automation"
  display_name = "VM Automation"
  description  = "Service account for VM automation workflows"
}

resource "google_service_account" "etl_job" {
  project      = var.project_id
  account_id   = "etl-job"
  display_name = "ETL Job"
  description  = "Service account for ETL jobs and data pipeline workflows"
}
