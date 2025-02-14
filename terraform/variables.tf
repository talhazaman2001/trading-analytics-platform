variable "aws_region" {
    description = "AWS Region"
    type = string
    default = "eu-west-2"
}   

variable "environment" {
    description = "Environment name"
    type = string
    default = "dev"
}

variable "project_name" {
    description = "Project name"
    type = string 
    default = "trading-analytics"
}

variable "instance_type" {
    description = "EC2 instance type"
    type = string 
    default = "t2.medium"
}

variable "vpc_cidr" {
    description = "VPC CIDR Block"
    type = string 
    default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
    description = "Public Subnet CIDR Blocks"
    type = list(string)
    default = [ "10.0.1.0/24", "10.0.2.0/24" ]
}

variable "private_subnet_cidrs" {
    description = "Private Subnet CIDR Blocks"
    type = list(string)
    default = [ "10.0.3.0/24", "10.0.4.0/24" ]
}

