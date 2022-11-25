resource "aws_s3_bucket" "bucket_for_ses_reports" {
  bucket          = "${var.prefix}-ses-reports"
  force_destroy   = true

  tags = {
    Name        = "ses-reports"
  }
}

resource "aws_s3_bucket_versioning" "bucket_for_ses_reports" {
  bucket = aws_s3_bucket.bucket_for_ses_reports.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket_for_ses_reports" {
  count = try(var.expiration_days, 0) == 0 ? 0 : 1

  bucket = aws_s3_bucket.bucket_for_ses_reports.id
  rule {
    id = "${var.prefix}-ses-reports"
    status = "Enabled"
    expiration {
      days = var.expiration_days
    }
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_for_ses_reports" {
  bucket = aws_s3_bucket.bucket_for_ses_reports.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
