terraform {

  required_version = ">= 1.3.7"

  cloud {
    workspaces {
      name = "aws-vpc"
    }
  }

  required_providers {
    env = {
      source  = "tchupp/env"
      version = "0.0.2"
    }

    tfe = {
      source  = "hashicorp/tfe"
      version = "0.42.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "4.53.0"
    }
  }
}

provider "env" {
  # use defaults
}

provider "tfe" {
  # use defaults
}

provider "aws" {
  region = local.aws_region
  default_tags {
    tags = local.aws_default_tags
  }
}
