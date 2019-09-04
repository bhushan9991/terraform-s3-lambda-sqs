
data "aws_s3_bucket" "s3_bucket" {
    bucket = "${var.bucket_name}"
}

#IAM Role for Lambda execution
resource "aws_iam_role" "lambda_role" {
    name = "${var.lambda_name}"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

#IAM Policies for Lambda Role
resource "aws_iam_policy" "sqs_policy" {
  name        = "sqs_policy"
  description = "lambda-sqs"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sqs:*"
      ],
      "Effect": "Allow",
      "Resource": "${aws_sqs_queue.sqs_queue.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "cloudwatch_policy" {
  name        = "cloudwatch_policy"
  description = "cloudwatch policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:*"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_role_policy_sqs" {
  role = "${aws_iam_role.lambda_role.id}"
  policy_arn = "${aws_iam_policy.sqs_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "lambda_role_policy_cloudwatch" {
  role = "${aws_iam_role.lambda_role.id}"
  policy_arn = "${aws_iam_policy.cloudwatch_policy.arn}"
}

#Lambda permissions
resource "aws_lambda_permission" "lambda_permissions" {
    statement_id = "AllowExecutionFromS3Bucket"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.lambda_function.arn}"
    principal = "s3.amazonaws.com"
    source_arn = "${data.aws_s3_bucket.s3_bucket.arn}"
}

#Creating Lambda Function
resource "aws_lambda_function" "lambda_function" {
    filename = "lambdafunction.zip"
    function_name = "${var.lambda_name}"
    role = "${aws_iam_role.lambda_role.arn}"
    handler = "lambdafunction.lambda_handler"
    runtime = "python3.6"
}

#Setting event trigger on existing s3 bucket
resource "aws_s3_bucket_notification" "bucket_notification" {
    bucket = "${data.aws_s3_bucket.s3_bucket.id}"
    lambda_function {
        lambda_function_arn = "${aws_lambda_function.lambda_function.arn}"
        events = ["s3:ObjectCreated:Put"]
        filter_prefix = "input-data/"
    }
}

#Creating sqs queue
resource "aws_sqs_queue" "sqs_queue" {
  name                      = "${var.sqs_name}"
  delay_seconds             = 0
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
}