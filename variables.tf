variable "prefix" {
  default = ""
}

variable "expiration_days" {
  default = 0
}

variable "ses_domain_identity" {
  description = "aws_ses_domain_identity arn"
}

variable "report_types" {
  default = [
    "bounce",
    "complaint",
    "delivery"
  ]
}