# Variable declarations
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_count" {
  description = "Number of instances to provision"
  type        = number
  default     = 2
}

variable "enable_nat_gateway" {
  description = "Enable a vpen gateway in your vpc"
  type        = bool
  default     = false
}

variable "public_subnets_count" {
  description = "Number of public subnets"
  type        = number
  default     = 2
}

variable "private_subnets_count" {
  description = "Number of private subnets"
  type        = number
  default     = 2
}

variable "public_subnets_cidr_blocks" {
  description = "Avariable cidr blocks for public subents"
  type        = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24",
  ]
}

variable "private_subnets_cidr_blocks" {
  description = "Avariable cidr block for private subnets"
  type        = list(string)
  default = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24",
  ]
}

variable "resource_tags" {
  description = "Tags to set for all resource"
  type        = map(string)
  default = {
    project     = "my-project"
    environment = "dev"
  }

  validation {
    condition = length(var.resource_tags["project"]) <= 16 && length(regexall("[^a-zA-Z0-9-]", var.resource_tags["project"])) == 0
    error_message = "Project tag must be no more than 16 characters."
  }

  validation {
    condition     = length(var.resource_tags["environment"]) <= 8 && length(regexall("[^a-zA-Z0-9-]", var.resource_tags["environment"])) == 0
    error_message = "The environment tag must be no more than 8 characters, and only contain letters, numbers, and hyphens."
  }
}

variable "ec2_instances_type" {
  description = "AWS EC2 instance type."
  type        = string
}

