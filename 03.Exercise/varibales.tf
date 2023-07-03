variable "aws_region" {
  description = "aws region"
  type        = string
  default     = "ap-southeast-1"
}


variable "private_subnet_cidr_blocks" {
  description = "avaiable cidr blocks for private subnets"
  type        = list(string)
  default = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24",
    "10.0.104.0/24",
    "10.0.105.0/24",
    "10.0.106.0/24",
    "10.0.107.0/24",
    "10.0.108.0/24",
  ]
}


variable "resource_tags" {
  description = "tags to set for all resources"
  type        = map(string)
  default = {
    "project"     = "project-name",
    "environment" = "dev"
  }
  validation {
    condition = length(var.resource_tags.project) <= 16 && length(regexall("[^a-zA-Z0-9-]", var.resource_tags["project"])) == 0

    error_message = "the project tag must be no more than 16 characters"
  }

  validation {
    condition     = length(var.resource_tags.environment) <= 8 && length(regexall("[^a-zA-Z0-9-]", var.resource_tags["environment"])) == 0
    error_message = "The environment tag must be no more than 8 characters, and only contain letters, numbers, and hyphens."
  }
}


variable "ec2_password" {
  description = "ec2 password"
  type        = string
  sensitive   = true
}
