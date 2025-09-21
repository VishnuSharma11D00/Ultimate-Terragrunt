# Terragrunt/terragrunt.hcl

# You'd usually use your credentials directly instead of github secrets, for testing the DEV environment locally

#  access_key = "${local.credentials.credentials.aws_access_key}"
#  secret_key = "${local.credentials.credentials.aws_secret_key}"

# locals {
#   credentials = yamldecode(file("./credentials.yaml"))
# }

locals {
  aws_region     = "ap-south-1"
  account_id     = "<ADD-YOUR-ACCOUNT-ID>"
  state_prefix   = "str-cat" 
  # make this very unique so there won't be state clash between different projects
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
    bucket = "${local.state_prefix}-tf-state"

    key = "${path_relative_to_include()}/terraform.tfstate"
    region = local.aws_region
    encrypt = true
    dynamodb_table = "${local.state_prefix}-terraform-lock-table"

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



