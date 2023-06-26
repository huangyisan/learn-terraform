terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  profile = "terraform"
  region  = "ap-southeast-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-073998ba87e205747"
  instance_type = "t2.micro"

  tags = {
    "Name"    = var.instance_name
    "Project" = "test"
  }
}
