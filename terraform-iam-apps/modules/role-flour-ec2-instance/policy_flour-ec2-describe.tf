data "aws_iam_policy_document" "policy_document_flour-ec2-describe" {

  ##
  # Autoscaling
  ##
  statement {
    sid = ""
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeTags"
    ]
    resources = ["*"]
  }

  ###
  # EC2
  ###
  statement {
    sid = ""
    actions = [
      "ec2:CreateTags",
      "ec2:Describe*",
    ]
    resources = ["*"]
  }

}

resource "aws_iam_policy" "flour-infra-ec2-describe" {
  name        = "flour-infra-ec2-describe"
  description = "flour Policy for EC2 describe permission"
  policy      = data.aws_iam_policy_document.policy_document_flour-ec2-describe.json
}
