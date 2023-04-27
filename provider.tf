terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = ">=1.2.0"
}

# Configure the AWS Provider
provider "aws" {
  access_key = "AKIAYO6YZNFJBAGBV7C2"
  region     = var.region
  secret_key = "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"
}
