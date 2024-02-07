resource "aws_iam_policy" "sarrionandia_s3" {
  name   = "sarrionandia_s3_policy"
  policy = templatefile("${path.module}/templates/sarrionandia_s3_policy.json", {})
}

resource "aws_iam_role" "sarrionandia" {
  name               = "sarrionandia_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "sarrionandia_s3" {
  role       = aws_iam_role.sarrionandia.name
  policy_arn = aws_iam_policy.sarrionandia_s3.arn
}
resource "aws_iam_instance_profile" "sarrionandia" {
  name = "sarrionandia_profile"
  role = aws_iam_role.sarrionandia.name
}
