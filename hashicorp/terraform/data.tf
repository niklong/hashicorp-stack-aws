
#
# import TF_CLOUD_ORGANIZATION environment variable
#
data "env_variable" "tf_cloud_organization" {
  name = "TF_CLOUD_ORGANIZATION"
}

#
# the organization identified by TF_CLOUD_ORGANIZATION
#
data "tfe_organization" "this" {
  name = data.env_variable.tf_cloud_organization.value
}

#
# the current workspace (terraform)
#
data "tfe_workspace" "this" {
  organization = data.tfe_organization.this.name
  name         = terraform.workspace
}

locals {

  # environment specific locals
  environment               = var.environment
  is_production_environment = var.environment == "Production"

  # normalize workspace variables
  workspace_variables = {
    for element in flatten([
      for workspace_name, workspace in local.workspaces : [
        for variable_name, variable in lookup(workspace, "variables", {}) : {
          workspace_name = workspace_name
          category       = variable.category
          default        = lookup(variable, "default_${local.environment}", lookup(variable, "default", null))
          sensitive      = lookup(variable, "sensitive", false)
          hcl            = lookup(variable, "hcl", false)
        } if(contains(keys(variable), "default_${local.environment}") || contains(keys(variable), "default"))
      ]
    ]) : element.workspace_name => element
  }

  # normalize worksplace variable sets
  workspace_variable_sets = {
    for element in flatten([
      for workspace_name, workspace in local.workspaces : [
        for variable_set_id in lookup(workspace, "variable_sets", []) : {
          workspace_name  = workspace_name
          variable_set_id = variable_set_id
        }
      ]
    ]) : "${element.workspace_name}_${element.variable_set_id}" => element
  }

  # normalize workspace run triggers
  workspace_run_triggers = {
    for element in flatten([
      for workspace_name, workspace in local.workspaces : [
        for sourceable_name in lookup(workspace, "run_triggers", []) : {
          workspace_name  = workspace_name
          sourceable_name = sourceable_name
        }
      ]
    ]) : "${element.workspace_name}_${element.sourceable_name}" => element
  }

  # our workspaces
  workspaces = {
    "aws-vpc" = {
      working_directory   = "/aws/vpc"
      global_remote_state = true
      variable_set_ids = {
        aws = tfe_variable_set.aws.id
      }
    }
  }
}
