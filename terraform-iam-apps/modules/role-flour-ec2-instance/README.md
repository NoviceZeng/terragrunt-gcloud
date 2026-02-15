## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.flour-ec2-instance-profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.flour-cmcs-access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.flour-infra-ec2-describe](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.flour-ec2-instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.node_instance_role_iam_policy_attachment-flour-cmcs-access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.node_instance_role_iam_policy_attachment-flour-ec2-describe](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.node_instance_role_iam_policy_attachment-flour-ec2-instance-profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.policy_document_flour-cmcs-access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.policy_document_flour-ec2-describe](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.policy_document_flour-ec2-instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_session_duration"></a> [session\_duration](#input\_session\_duration) | Session Duration | `number` | `7200` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_flour_ec2_instance_role_arn"></a> [flour\_ec2\_instance\_role\_arn](#output\_flour\_ec2\_instance\_role\_arn) | IAM role ARN |
| <a name="output_flour_ec2_instance_role_name"></a> [flour\_ec2\_instance\_role\_name](#output\_flour\_ec2\_instance\_role\_name) | IAM Role Name |
| <a name="output_flour_ec2_instance_role_name_description"></a> [flour\_ec2\_instance\_role\_name\_description](#output\_flour\_ec2\_instance\_role\_name\_description) | IAM Role Description |
