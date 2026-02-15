data "aws_iam_policy_document" "policy_document_flour-ec2-instance" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "flour-ec2-instance" {
  name                 = "flour-ec2-instance"
  description          = "flour Instance Role"
  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/ais-permissions-boundaries"
  max_session_duration = var.session_duration
  assume_role_policy   = data.aws_iam_policy_document.policy_document_flour-ec2-instance.json
  tags = {
    accessreviewscope = "yes"
  }
}

# Describe autoscalinggroup & ec2 instances
resource "aws_iam_role_policy_attachment" "node_instance_role_iam_policy_attachment-flour-ec2-describe" {
  role       = aws_iam_role.flour-ec2-instance.name
  policy_arn = aws_iam_policy.flour-infra-ec2-describe.arn
}

resource "aws_iam_instance_profile" "flour-ec2-instance-profile" {
  name = "flour-ec2-instance-profile"
  role = aws_iam_role.flour-ec2-instance.id
}

##############
# Define a custom IAM role
resource "google_iam_custom_role" "my_custom_viewer" {
  role_id     = "myCustomViewer"
  title       = "My Custom Viewer Role"
  description = "Custom role with specific viewing permissions"
  permissions = [
    "compute.instances.get",
    "compute.instances.list",
    "storage.buckets.get",
    "storage.buckets.list",
  ]
  stage = "GA" # Or ALPHA, BETA
  project = var.project_id # Or organization = var.org_id
}

# Assign the custom role to a user at the project level
resource "google_project_iam_member" "custom_role_assignment" {
  project = var.project_id
  role    = google_iam_custom_role.my_custom_viewer.name
  member  = "user:your-user@example.com"
}

# Assign a predefined role to a service account
resource "google_project_iam_member" "service_account_viewer" {
  project = var.project_id
  role    = "roles/viewer"
  member  = "serviceAccount:my-service-account@${var.project_id}.iam.gserviceaccount.com"
}
