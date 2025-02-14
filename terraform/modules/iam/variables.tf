variable "environment" {
    type = string
    description = "Environment"
}

variable "project_name" {
    type = string
    description = "Project Name"
}

variable "s3_bucket_arn" {
    type = string
    description = "S3 Logs Bucket ARN"
}

variable "sqs_queue_arn" {
    type = string
    description = "SQS Queue ARN"
}   
