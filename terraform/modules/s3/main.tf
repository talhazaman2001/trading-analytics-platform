# S3 Bucket for Trading Logs
resource "aws_s3_bucket" "logs" {
    bucket = "${var.project_name}-${var.environment}-logs"

    tags = {
       Name = "${var.project_name}-${var.environment}-logs" 
       Environment = var.environment
       Project = var.project_name
    }
}

# S3 Bucket Versioning 
resource "aws_s3_bucket_versioning" "logs" {
    bucket = aws_s3_bucket.logs.id
    versioning_configuration {
        status = "Enabled"
    } 
}

# Public access block
resource "aws_s3_bucket_public_access_block" "logs" {
    bucket = aws_s3_bucket.logs.id

    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

# Lifecycle rule for Logs Bucket
resource "aws_s3_bucket_lifecycle_configuration" "logs" {
    bucket = aws_s3_bucket.logs.id

    rule {
        id = "logs"
        status = "Enabled"

        transition {
            days = 90
            storage_class = "GLACIER_IR"
        }

        transition {
            days = 365
            storage_class = "DEEP_ARCHIVE"
        }

        expiration {
            days = 2555 # 7 Years
        }

         noncurrent_version_transition {
            noncurrent_days = 90
            storage_class = "GLACIER_IR"
        }

        noncurrent_version_transition {
            noncurrent_days = 365
            storage_class = "DEEP_ARCHIVE"
        }

        noncurrent_version_expiration {
            noncurrent_days = 2555 # 7 Years
        }
    }
}

# SQS Queue for S3 events
resource "aws_sqs_queue" "s3_events" {
    name = "${var.project_name}-${var.environment}-s3-events"
    delay_seconds = 0
    max_message_size = 262144  # 256 KB
    message_retention_seconds = 345600  # 4 days
    receive_wait_time_seconds = 0
    visibility_timeout_seconds = 30
    redrive_policy = jsonencode({
        deadLetterTargetArn = aws_sqs_queue.s3_events_dlq.arn
        maxReceiveCount = 4
    })

    tags = {
        Name = "${var.project_name}-${var.environment}-s3-events"
        Environment = var.environment
        Project     = var.project_name
    }
}

# Dead Letter Queue for failed messages
resource "aws_sqs_queue" "s3_events_dlq" {
    name = "${var.project_name}-${var.environment}-s3-events-dlq"
    
    message_retention_seconds = 1209600  # 14 days
    
    tags = {
        Name = "${var.project_name}-${var.environment}-s3-events-dlq"
        Environment = var.environment
        Project = var.project_name
    }
}

# SQS Queue Policy
resource "aws_sqs_queue_policy" "s3_events_policy" {
    queue_url = aws_sqs_queue.s3_events.url
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = { Service = "s3.amazonaws.com" }
            Action = "sqs:SendMessage"
            Resource = aws_sqs_queue.s3_events.arn
            Condition = {
                ArnLike = { "aws:SourceArn": aws_s3_bucket.logs.arn }
            }
        }]
    })
}


# S3 Event notification
resource "aws_s3_bucket_notification" "bucket_notification" {
    bucket = aws_s3_bucket.logs.id

    queue {
        queue_arn = aws_sqs_queue.s3_events.arn
        events = ["s3:ObjectCreated:*"]
        filter_suffix = ".log"  
    }
}