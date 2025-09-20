# lambdas/terragrunt.hcl

terraform {
  source = "git::https://github.com/VishnuSharma11D00/infrastructure-modules.git//lambda?ref=lambda-v0.1.1"
}

include "root" {
  path = find_in_parent_folders()
  expose = true
}


include "mock_outputs" {
  path = "${get_terragrunt_dir()}/mock_outputs.hcl"
  expose = true
}

dependency "dynamodb" {
  config_path = "../dynamodb"

  mock_outputs = include.mock_outputs.locals.mock_outputs_dynamodb
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

locals {
  lambda_code_path = "${get_terragrunt_dir()}/../../../lambda-codes-dev"
  my_region        = include.root.locals.aws_region
  account_Id       = tostring(include.root.locals.account_id)
  lambda_prefix    = "FE"
  tag_value = "terragrunt_frontend"
  env = include.root.locals.env
}

inputs = {
  env = local.env
  aws_region = local.my_region
  account_id = local.account_Id
  prefix = local.lambda_prefix
  
    lambda_functions = {
    lambda1 = {
        name        = "StrengthCat"
        zip_file    = "${local.lambda_code_path}/lambda.zip"
        policy_name = "StrengthCat_lambda-policy"
        tagValue    = local.tag_value
        environment_variables = {
          DYNAMODB_TABLE_NAME = dependency.dynamodb.outputs.table_details["table1"].name
        }
        policy_document = {
          Version = "2012-10-17"
          Statement = [
            {
              Sid      = "DynamoDBWriteAccess"
              Effect   = "Allow"
              Action   = ["dynamodb:PutItem", "dynamodb:UpdateItem"]              
              Resource = [
                dependency.dynamodb.outputs.table_details["table1"].arn
              ]
            }
          ]
        }
    },
    lambda2 = {
        name        = "History"
        zip_file    = "${local.lambda_code_path}/lambda_history.zip"
        policy_name = "History_lambda-policy"
        tagValue    = local.tag_value
        environment_variables = {
          DYNAMODB_TABLE_NAME = dependency.dynamodb.outputs.table_details["table1"].name
        }
        policy_document = {
          Version = "2012-10-17"
          Statement = [
            {
              Sid      = "DynamoDBQueryAccess"
              Effect   = "Allow"
              Action   = ["dynamodb:Query"]              
              Resource = [
                dependency.dynamodb.outputs.table_details["table1"].arn
              ]
            }
          ]
        }
    }
  }
}