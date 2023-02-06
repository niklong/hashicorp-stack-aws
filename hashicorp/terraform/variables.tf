
#
# Terraform
#
variable "terraform_version" {
  type    = string
  default = "1.3.7" # current version
}

variable "environment" {
  type = string

  validation {
    condition     = contains(["Development", "Staging", "Production"], var.environment)
    error_message = "Environment must be one of: Development, Staging or Production"
  }
}

#
# GitHub
#
variable "vcs_github_oauth_token_id" {
  type = string
}

variable "vcs_github_identifier" {
  type = string
}

variable "vcs_github_branch" {
  type = string
}
