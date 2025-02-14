variable "vpc_cidr" {
    type = string
    description = "VPC CIDR Block"
}

variable "public_subnet_cidrs" {
    type = list(string)
    description = "Public Subnet CIDR Blocks"
}

variable "private_subnet_cidrs" {
    type = list(string)
    description = "Private Subnet CIDR Blocks"
}

variable "environment" {
    type = string
    description = "Environment"
}

variable "project_name" {
    type = string
    description = "Project Name"
}

variable "aws_region" {
    type = string
    default = "eu-west-2"
}

variable "elk_sg_id" {
    type = string
    description = "ELK Security Group ID"
}