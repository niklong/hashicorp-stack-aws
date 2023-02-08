
data "env_variable" "tf_cloud_organization" {
  name = "TF_CLOUD_ORGANIZATION"
}

data "tfe_outputs" "terraform" {
  organization = data.env_variable.tf_cloud_organization.value
  workspace    = "terraform"
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  #
  # environment
  #
  environment = nonsensitive(data.tfe_outputs.terraform.values.environment)

  #
  # AWS provider settings
  #
  aws_default_tags = {
    Solution    = "Getting Started with Hashicorp"
    Environment = local.environment
    Tool        = "Terraform"
  }
  aws_region = var.aws_region

  #
  # VPC
  #
  vpc_name               = "hashistack-vpc"
  vpc_cidr_block         = var.vpc_cidr_block
  vpc_availability_zones = data.aws_availability_zones.available.names
  vpc_default_tags = {
    Name = local.vpc_name
  }

  #
  # public subnet
  #
  vpc_public_subnet_start         = 0
  vpc_public_subnet_count         = 3
  vpc_public_subnet_end           = local.vpc_public_subnet_start + local.vpc_public_subnet_count
  vpc_public_subnet_cidr_blocks   = slice(cidrsubnets(local.vpc_cidr_block, [for v in range(local.vpc_public_subnet_end) : 8]...), local.vpc_public_subnet_start, local.vpc_public_subnet_end)
  vpc_public_subnet_ipv6_prefixes = range(local.vpc_public_subnet_start, local.vpc_public_subnet_end)

  #
  # private subnet
  #
  vpc_private_subnet_start         = 12
  vpc_private_subnet_count         = 3
  vpc_private_subnet_end           = local.vpc_private_subnet_start + local.vpc_private_subnet_count
  vpc_private_subnet_cidr_blocks   = slice(cidrsubnets(local.vpc_cidr_block, [for v in range(local.vpc_private_subnet_end) : 8]...), local.vpc_private_subnet_start, local.vpc_private_subnet_end)
  vpc_private_subnet_ipv6_prefixes = range(local.vpc_private_subnet_start, local.vpc_private_subnet_end)

  #
  # network ACLs
  #
  vpc_network_acls = {
    #
    # default ACLs
    #
    default_inbound = []
    default_outbound = [
      {
        rule_number = 1000
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      }
    ]

    #
    # public ACLs
    #
    public_inbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      }
    ]
    public_outbound = []

    #
    # private ACLs
    #
    private_inbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = local.vpc_cidr_block
      }
    ]
    private_outbound = []
  }
}
