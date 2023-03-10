
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"

  # network
  name                 = local.vpc_name
  cidr                 = local.vpc_cidr_block
  azs                  = local.vpc_availability_zones
  public_subnets       = local.vpc_public_subnet_cidr_blocks
  private_subnets      = local.vpc_private_subnet_cidr_blocks
  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_nat_gateway   = true
  single_nat_gateway   = true

  # IPv6
  enable_ipv6                                    = true
  assign_ipv6_address_on_creation                = true
  public_subnet_ipv6_prefixes                    = local.vpc_public_subnet_ipv6_prefixes
  private_subnet_assign_ipv6_address_on_creation = true
  private_subnet_ipv6_prefixes                   = local.vpc_private_subnet_ipv6_prefixes

  # network ACLs
  manage_default_network_acl = true
  default_network_acl_tags   = local.vpc_default_tags

  # public ACLs
  public_dedicated_network_acl = false
  public_inbound_acl_rules     = concat(local.vpc_network_acls.default_inbound, local.vpc_network_acls.public_inbound)
  public_outbound_acl_rules    = concat(local.vpc_network_acls.default_outbound, local.vpc_network_acls.public_outbound)

  # private ACLs
  private_dedicated_network_acl = false
  private_inbound_acl_rules     = concat(local.vpc_network_acls.default_inbound, local.vpc_network_acls.private_inbound)
  private_outbound_acl_rules    = concat(local.vpc_network_acls.default_outbound, local.vpc_network_acls.private_outbound)

  # default route table
  manage_default_route_table = true
  default_route_table_tags   = local.vpc_default_tags

  # default security group
  manage_default_security_group = true
  default_security_group_tags   = local.vpc_default_tags
}

#
# VPC endpoints
#
module "vpc_endpoints" {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc//modules/vpc-endpoints?ref=v3.14.0"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [module.vpc.default_security_group_id]

  endpoints = {
    sts = {
      service             = "sts"
      private_dns_enabled = true
      subnet_ids          = module.vpc.public_subnets
      policy              = data.aws_iam_policy_document.vpc_endpoints_policy.json
      security_group_ids  = [aws_security_group.vpc_endpoints_tls.id]
    },
    autoscaling = {
      service             = "autoscaling"
      private_dns_enabled = true
      subnet_ids          = module.vpc.public_subnets
      security_group_ids  = [aws_security_group.vpc_endpoints_tls.id]
    },
    ec2 = {
      service             = "ec2"
      private_dns_enabled = true
      subnet_ids          = module.vpc.public_subnets
      security_group_ids  = [aws_security_group.vpc_endpoints_tls.id]
    }
  }
}

resource "aws_security_group" "vpc_endpoints_tls" {
  name_prefix = "vpc-endpoints-tls"
  description = "Allow inbound TLS taffic to VPC endpoints"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [
      module.vpc.vpc_cidr_block
    ]
  }

  tags = {
    Name = "sg-vpc-endpoints-tls"
  }
}

data "aws_iam_policy_document" "vpc_endpoints_policy" {
  statement {
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "aws:sourceVpc"
      values = [
        module.vpc.vpc_id
      ]
    }
  }
}
