
locals {
  # map the workspace name to the workspace id for later lookups
  workspace_ids = {
    for workspace in tfe_workspace.this : workspace.name => workspace.id
  }
}

#
# workspaces
#
resource "tfe_workspace" "this" {

  # only enabled workspaces
  for_each = {
    for workspace_name, workspace in local.workspaces : workspace_name => workspace if lookup(workspace, "enable", true)
  }

  # workspace settings
  terraform_version   = var.terraform_version
  organization        = data.tfe_organization.this.name
  name                = each.key
  global_remote_state = each.value.global_remote_state
  working_directory   = each.value.working_directory

  # workspace trigger patterns
  trigger_patterns = concat(
    ["${each.value.working_directory}/**/*"],
    lookup(each.value, "trigger_patterns", [])
  )

  # environment specific, more cautious in production
  allow_destroy_plan = !local.is_production_environment
  auto_apply         = !local.is_production_environment

  # defaults applying to all environments
  queue_all_runs                = false
  file_triggers_enabled         = true
  speculative_enabled           = true
  structured_run_output_enabled = true

  # VCS settings
  vcs_repo {
    identifier     = var.vcs_github_identifier
    branch         = var.vcs_github_branch
    oauth_token_id = var.vcs_github_oauth_token_id
  }

  lifecycle {
    prevent_destroy = true
  }
}

#
# workspace variables
#
resource "tfe_variable" "this" {
  for_each     = local.workspace_variables
  workspace_id = lookup(local.workspace_ids, each.value.workspace_name, null)
  key          = each.key
  value        = each.value.default
  category     = each.value.category
  sensitive    = each.value.sensitive
  hcl          = each.value.hcl

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}

#
# variable set associations
#
resource "tfe_workspace_variable_set" "this" {
  for_each        = local.workspace_variable_sets
  workspace_id    = lookup(local.workspace_ids, each.value.workspace_name, null)
  variable_set_id = each.value.variable_set_id
}

#
# workspace run triggers
#
resource "tfe_run_trigger" "this" {
  for_each      = local.workspace_run_triggers
  workspace_id  = lookup(local.workspace_ids, each.value.workspace_name, null)
  sourceable_id = lookup(local.workspace_ids, each.value.sourceable_name, null)
}
