# Terragrunt/dynamodb/terragrunt.hcl

terraform {
  source = "git::https://github.com/VishnuSharma11D00/infrastructure-modules.git//dynamodb?ref=dynamodb-v0.0.1"
}

locals {
  config      = yamldecode(file("dynamodb_config.yaml"))
}

include "root" {
  path = find_in_parent_folders()
  expose = true
}


inputs = {
  dynamodb_tables = local.config.dynamodb_tables
 env              = include.root.locals.env
}
