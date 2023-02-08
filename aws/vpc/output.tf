
output "environment" {
  value = local.environment
}

output "aws_default_tags" {
  value = local.aws_default_tags
}

output "aws_region" {
  value = local.aws_region
}

output "vpc_cidr_block" {
  value = local.vpc_cidr_block
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
