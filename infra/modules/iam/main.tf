resource "aws_iam_role" "this" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "s3_access" {
  name = "${var.role_name}-s3-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::*-raw-*",
          "arn:aws:s3:::*-replicated-*",
          "arn:aws:s3:::*-unified-*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = [
          "arn:aws:s3:::*-raw-*/*",
          "arn:aws:s3:::*-replicated-*/*",
          "arn:aws:s3:::*-unified-*/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.s3_access.arn
}


resource "aws_iam_instance_profile" "this" {
  name = "${var.role_name}-profile"
  role = aws_iam_role.this.name
}

resource "aws_iam_role" "lambda_role" {

  name = "hop-trigger-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"

      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {

  role = aws_iam_role.lambda_role.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


resource "aws_iam_role" "dms_role" {

  name = "dms-s3-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "dms.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })
}


resource "aws_iam_policy" "dms_s3_policy" {

  name = "dms-s3-policy"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Action = [
        "s3:*"
      ]

      Resource = [
        "arn:aws:s3:::${var.raw_bucket}",
        "arn:aws:s3:::${var.raw_bucket}/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "dms_attach" {

  role = aws_iam_role.dms_role.name

  policy_arn = aws_iam_policy.dms_s3_policy.arn
}