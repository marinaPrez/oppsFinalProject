## IAM role - Jenkins
resource "aws_iam_role" "jenkins-role" {
  name = "jenkins-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "jenkins-policy" {
  name        = "jenkins-policy"
  description = "jenkins policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "ec2:*",
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "autoscaling:*",
            "Resource": "*"
        },
        {
            "Action": "eks:*",
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "jenkins-policy-attach" {
  role       = aws_iam_role.jenkins-role.name
  policy_arn = aws_iam_policy.jenkins-policy.arn
}


resource "aws_iam_instance_profile" "jenkins-role" {
  name  = "jenkins-role-profile"
  role = aws_iam_role.jenkins-role.name
}

