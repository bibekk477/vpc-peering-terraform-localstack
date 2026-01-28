terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Default provider (required)
provider "aws" {
  region     = var.primary
  access_key = "test"
  secret_key  = "test"

  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  skip_region_validation      = true

  endpoints {
    ec2      = var.localstack_endpoint
    s3       = var.localstack_endpoint
    dynamodb = var.localstack_endpoint
    sts      = var.localstack_endpoint
    iam      = var.localstack_endpoint
  }
}

# Primary provider with alias
provider "aws" {
  region     = var.primary
  alias      = "primary"
  access_key = "test"
  secret_key  = "test"

  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  skip_region_validation      = true

  endpoints {
    ec2      = var.localstack_endpoint
    s3       = var.localstack_endpoint
    dynamodb = var.localstack_endpoint
    sts      = var.localstack_endpoint
    iam      = var.localstack_endpoint
  }
}

# Secondary provider with alias
provider "aws" {
  region     = var.secondary
  alias      = "secondary"
  access_key = "test"
  secret_key  = "test"

  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  skip_region_validation      = true

  endpoints {
    ec2      = var.localstack_endpoint
    s3       = var.localstack_endpoint
    dynamodb = var.localstack_endpoint
    sts      = var.localstack_endpoint
    iam      = var.localstack_endpoint
  }
}