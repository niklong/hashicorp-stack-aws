
#
# Terraform
#
variable "terraform_version" {
  type    = string
  default = ">= 1.3.7" # current version
}

variable "environment" {
  type = string

  validation {
    condition     = contains(["Development", "Staging", "Production"], var.environment)
    error_message = "Environment must be one of: Development, Staging or Production"
  }
}
