# String type
variable "environment" {
  type        = string
  description = "The environment type"
  default     = "prod"
}
variable "localstack_endpoint" {
  type        = string
  description = "LocalStack endpoint URL"
  default     = "http://localhost:4566"
}
variable "primary" {
  type        = string
  description = "Primary AWS region for resources"
  default     = "us-east-1"
}

variable "secondary" {
  type        = string
  description = "Secondary AWS region for resources"
  default     = "us-west-2"
}

variable "primary_vpc_cidr" {
  type        = string
  description = "CIDR block for the primary VPC"
  default     = "10.0.0.0/16"
}

variable "secondary_vpc_cidr" {
  type        = string
  description = "CIDR block for the secondary VPC"
  default     = "10.1.0.0/16"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t2.micro"
  
}

variable "primary_subnet_cidr" {
  type        = string
  description = "CIDR block for primary subnet"
  default     = "10.0.1.0/24"
  }
variable "secondary_subnet_cidr" {  
  type        = string
  description = "CIDR block for secondary subnet"
  default     = "10.1.1.0/24"
  }
variable "primary_key_name" {
  type        = string
  description = "Name of ssh key pair for primary VPC instance"
  }
variable "secondary_key_name" {
  type        = string
  description = "Name of ssh key pair for secondary VPC instance"
  }