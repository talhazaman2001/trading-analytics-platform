output "s3_bucket_arn" {
    value = aws_s3_bucket.logs.arn
}

output "s3_sqs_queue_url" {
    value = aws_sqs_queue.s3_events.url
}

output "sqs_queue_arn" {
    value = aws_sqs_queue.s3_events.arn
}