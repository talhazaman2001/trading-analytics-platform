variable "vpc_id" {
    type = string
    description = "ID of VPC"
}

variable "public_subnet_ids" {
    type = list(string)
    description = "Public Subnet IDs"
}

variable "private_subnet_ids" {
    type = list(string)
    description = "Private Subnet IDs"
}

variable "instance_type" {
    type = string
    description = "EC2 Instance Type"
    default = "t2.medium"
}

variable "environment" {
    type = string
    description = "Environment name"
}

variable "project_name" {
    type = string
    description = "Project name"
}

variable "iam_instance_profile" {
    type = string 
    description = "EC2 instance profile"
}

variable "desired_capacity" {
    default = 2
}

variable "min_size" {
    default = 2
}

variable "max_size" {
    default = 4
}

variable "target_group_arn" {
    description = "ALB target group ARN"
    type = string
}

variable "s3_sqs_queue_url" {
    description = "URL of SQS Queue for S3 event notifications"
    type = string
}

variable "aws_region" {
    description = "AWS region where resources will be created"
    type        = string
}