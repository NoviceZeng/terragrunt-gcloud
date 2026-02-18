remote_state {
  backend = "gcs"
  config = {
    bucket = "YOUR-TFSTATE-BUCKET"
    prefix = "terraform/state"
  }
}