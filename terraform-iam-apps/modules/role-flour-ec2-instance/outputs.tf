###
# Outputs (IAM)
###

output "flour_ec2_instance_role_name" {
  description = "IAM Role Name"
  value       = aws_iam_role.flour-ec2-instance.name
}

output "flour_ec2_instance_role_name_description" {
  description = "IAM Role Description"
  value       = aws_iam_role.flour-ec2-instance.description
}

output "flour_ec2_instance_role_arn" {
  description = "IAM role ARN"
  value       = aws_iam_role.flour-ec2-instance.arn
}
