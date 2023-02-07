terraform {

  # minimum required terraform version
  required_version = ">= 1.3.7"

  cloud {
    workspaces {
      name = "terraform"
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

  }
}

provider "env" {
  # use defaults
}

provider "tfe" {
  # use defaults
}
