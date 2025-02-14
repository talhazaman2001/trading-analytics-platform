variable "environment" {
    type = string
    description = "Environment name"
}

variable "project_name" {
    type = string
    description = "Project name"
}

variable "vpc_id" {
    type = string
    description = "ID of VPC"
}

variable "public_subnet_ids" {
    type = list(string)
    description = "Public Subnet IDs"
}