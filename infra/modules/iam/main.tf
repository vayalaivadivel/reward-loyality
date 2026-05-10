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



#########################################
# DMS VPC ROLE
#########################################

resource "aws_iam_role" "dms_vpc_role" {

  name = "dms-vpc-role-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "dms.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

#########################################
# ATTACH AWS MANAGED POLICY
#########################################

resource "aws_iam_role_policy_attachment" "dms_vpc_attach" {

  role = aws_iam_role.dms_vpc_role.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
}


#########################################
# DMS ACCESS ROLE
#########################################

resource "aws_iam_role" "dms_role" {

  name = "${var.project}-${var.env}-dms-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "dms.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dms_attach" {

  role = aws_iam_role.dms_role.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
}

resource "aws_iam_role" "dms_logs_role" {

  name = "dms-cloudwatch-logs-role-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "dms.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dms_logs_attach" {

  role = aws_iam_role.dms_logs_role.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"
}