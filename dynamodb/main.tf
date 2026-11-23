
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"

  default_tags {
    tags = {
      Project = "JennyOma-Week3-DynamoDB-Lab"
      Purpose = "AWS-SAA-Training"
    }
  }
}

resource "aws_dynamodb_table" "documents" {
  name         = "JennyOma-Week3-Documents"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "UserID"
  range_key = "DocumentID"

  attribute {
    name = "UserID"
    type = "S"
  }

  attribute {
    name = "DocumentID"
    type = "S"
  }
}

output "table_name" {
  value = aws_dynamodb_table.documents.name
}