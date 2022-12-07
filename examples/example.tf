data "aws_ses_domain_identity" "example" {
  domain = "example.com"
}

module "example" {
  source = "github.com/silksh-terraform-modules/terraform-aws-ses-reports?ref=v0.0.1"

  prefix = "example" # bucket, function & role names
  ses_domain_identity = data.aws_ses_domain_identity.example.arn

  expiration_days = 10

  report_types = [
    "bounce",
    "complaint",
    "delivery"
  ]
}
