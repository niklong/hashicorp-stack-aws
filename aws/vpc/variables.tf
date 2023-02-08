
variable "environment" {
  type    = string
  default = null
  validation {
    condition     = var.environment == null ? true : contains(["Production", "Staging", "Development", "Research"], var.environment)
    error_message = "The environment value must be one of: Production, Staging, Development, or Research"
  }
}

variable "aws_region" {
  type    = string
  default = "ap-southeast-2"
}

variable "vpc_cidr_block" {
  type    = string
  default = "172.16.0.0/16"
}
