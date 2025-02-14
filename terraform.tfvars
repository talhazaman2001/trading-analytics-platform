# Project Information
project_name = "trading-analytics"
environment = "dev"
aws_region = "eu-west-2"

# Instance Configuration
instance_type = "t2.medium"
desired_capacity = 2
min_size = 2
max_size = 4

# VPC Configuration
vpc_cidr = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]

# ELK Stack Configuration
elasticsearch_version = "7.10.0"

s3_sqs_queue_url = "https://sqs.amazonaws.com/463470963000/trading-analytics-dev-s3-events"