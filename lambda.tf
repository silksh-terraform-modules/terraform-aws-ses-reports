resource "aws_sns_topic" "ses_reports" {
  for_each = toset(var.report_types)
  
  name = "${each.key}-ses-reports"
}

resource "aws_sns_topic_subscription" "ses_reports_subscriptions" {
  for_each = toset(var.report_types)

  topic_arn = aws_sns_topic.ses_reports[each.key].arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.lambda_for_ses_reports[each.key].arn
}

resource "aws_ses_identity_notification_topic" "ses_reports" {
  for_each = toset(var.report_types)
  
  topic_arn                = aws_sns_topic.ses_reports[each.key].arn
  notification_type        = title("${each.key}")
  identity                 = "${var.ses_domain_identity}"
  include_original_headers = true
}

resource "aws_lambda_function" "lambda_for_ses_reports" {
  for_each = toset(var.report_types)

  function_name = "${var.prefix}_ses_reports_${each.key}"
  filename = "${path.module}/function/index.js.zip"
  # source_code_hash = filebase64sha256("function/index.js.zip")

  handler = "index.handler"
  runtime = "nodejs16.x"
  # timeout = var.lambda_function_timeout
  
  role = aws_iam_role.lambda_for_ses_reports.arn

  environment {
    variables = {
      S3_BUCKET_NAME = "${var.prefix}-ses-reports"
      BUCKET_PATH = "${each.key}"
    }
  }

  depends_on = [
    data.archive_file.lambda_for_ses_reports
  ]
}

resource "aws_lambda_permission" "lambda_for_ses_reports" {
  for_each = toset(var.report_types)

  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_for_ses_reports[each.key].function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.ses_reports[each.key].arn
}

data "archive_file" "lambda_for_ses_reports" {
  type             = "zip"
  source_file = "${path.module}/function/index.js"
  output_path = "${path.module}/function/index.js.zip"
}

resource "aws_iam_role" "lambda_for_ses_reports" {
  name = "${var.prefix}_lambda_ses_reports"

  managed_policy_arns = []

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_for_ses_reports" {
  role = aws_iam_role.lambda_for_ses_reports.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Resource": [
        "${aws_s3_bucket.bucket_for_ses_reports.arn}",
        "${aws_s3_bucket.bucket_for_ses_reports.arn}/*"
      ]
    }
  ]
}
EOF
}
