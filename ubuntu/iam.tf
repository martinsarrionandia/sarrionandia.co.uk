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

resource "aws_iam_user" "sarrionandia_s3" {
  name = "sarrionandia-s3-access"

  tags = {
    Name= "sarrionandia-s3-access"
  }
}

resource "aws_iam_access_key" "sarrionandia_s3" {
  user = aws_iam_user.sarrionandia_s3.name
}

resource "aws_iam_user_policy" "sarrionandia_s3" {
  name   = "test"
  user   = aws_iam_user.sarrionandia_s3.name
  policy = aws_iam_policy.sarrionandia_s3.policy
}

resource "aws_secretsmanager_secret" "sarrionandia_s3_access" {
  name = "sarrionandia_s3_access"
  description = "AWS Access key and Secret for sarrionandia_s3_access user"
  kms_key_id = data.aws_kms_key.sarrionandia.id
}

resource "aws_secretsmanager_secret_version" "sarrionandia_s3_access_current" {
  secret_id     = aws_secretsmanager_secret.sarrionandia_s3_access.id
  secret_string = jsonencode({
    aws_access_key_id = aws_iam_access_key.sarrionandia_s3.id
    aws_secret_access_key = aws_iam_access_key.sarrionandia_s3.secret
  })
}