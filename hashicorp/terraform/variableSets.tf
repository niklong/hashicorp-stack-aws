#
# AWS credentials
#
resource "tfe_variable_set" "aws" {
  organization = data.tfe_organization.this.name
  name         = "AWS"
  global       = true
}

resource "tfe_variable" "aws_access_key" {
  variable_set_id = tfe_variable_set.aws.id
  category        = "env"
  key             = "AWS_ACCESS_KEY_ID"
  value           = ""
  sensitive       = true

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

resource "tfe_variable" "aws_secret_key" {
  variable_set_id = tfe_variable_set.aws.id
  category        = "env"
  key             = "AWS_SECRET_ACCESS_KEY"
  value           = ""
  sensitive       = true

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}
