# Terragrunt/terragrunt.hcl

include "env" {
  path = "./env.hcl"
  expose = true
  merge_strategy = "no_merge"
}

locals {
  aws_region     = get_env("AWS_REGION", "ap-south-1")
  account_id     = get_env("ACCOUNT_ID", "")
  env            = "prod"
}

remote_state {
  backend = "s3"
  generate = {
    path      = "state.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    # profile = "Terraform" no need for this when it is doing aws configure in github actions
    bucket = "tharive-tf-state"

    key = "${local.env}/terraform.tfstate"
    region = local.aws_region
    encrypt = true
    dynamodb_table = "terraform-lock-table"

    assume_role = {
      role_arn = "arn:aws:iam::${local.account_id}:role/terraform"
    }
  }
}


generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region     = "${local.aws_region}"
  # profile = "Terraform"

  assume_role {
    # (valid ~1 hour by default and session name helps audit logs)
    session_name = "strcat-prod"
    role_arn = "arn:aws:iam::${local.account_id}:role/terraform"
  }
 
}
EOF
}



