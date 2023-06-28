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

# resource "aws_instance" "app_server" {
#   ami           = "ami-073998ba87e205747"
#   instance_type = "t2.micro"

#   tags = {
#     "Name"    = var.instance_name
#     "Project" = "ubuntu"
#     "monitor" = "true"
#   }
# }
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "production"
  }
}

resource "aws_subnet" "main_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "main-subnet"
  }
}

resource "aws_subnet" "main_subnet02" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "main-subnet02"
  }
}
