# Terragrunt/terragrunt.hcl

include "env" {
  path = "./env.hcl"
  expose = true
  merge_strategy = "no_merge"
}

# You'd usually use your credentials directly instead of github secrets, for testing the DEV environment locally

#  access_key = "${local.credentials.credentials.aws_access_key}"
#  secret_key = "${local.credentials.credentials.aws_secret_key}"

# locals {
#   credentials = yamldecode(file("./credentials.yaml"))
# }

locals {
  aws_region     = "ap-south-1"
  account_id     = "<ADD-YOUR-ACCOUNT-ID>"
  env            = include.env.locals.env
}

remote_state {
  backend = "s3"
  generate = {
    path      = "state.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    # profile is when you do aws login locally with your 'Terraform' user profile
    profile = "Terraform"
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
  profile = "Terraform"

  assume_role {
    session_name = "strcat-dev"
    role_arn = "arn:aws:iam::${local.account_id}:role/terraform"
  }
 
}
EOF
}



