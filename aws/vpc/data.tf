
data "env_variable" "tf_cloud_organization" {
  name = "TF_CLOUD_ORGANIZATION"
}

data "tfe_outputs" "terraform" {
  organization = data.env_variable.tf_cloud_organization.value
  workspace    = "terraform"
}

locals {

  environment = nonsensitive(data.tfe_outputs.terraform.values.environment)

  default_tags = {
    Solution    = "Getting Started with Hashicorp"
    Environment = local.environment
    Tool        = "Terraform"
  }

  aws_region = var.aws_region
}
