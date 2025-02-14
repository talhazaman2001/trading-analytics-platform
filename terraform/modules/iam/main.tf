# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
    name = "${var.project_name}-${var.environment}-ec2-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            }
        ]
    })
}

# IAM Policy for EC2 to access S3
resource "aws_iam_role_policy" "s3_access" {
    name = "${var.project_name}-${var.environment}-s3-access"
    role = aws_iam_role.ec2_role.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "s3:GetObject",
                    "s3:ListBucket",
                    "s3:PutObject"
                ]
                Resource = [
                    var.s3_bucket_arn,
                    "${var.s3_bucket_arn}/*"
                ]
            }
        ]
    })
}

# IAM Policy for EC2 to read from SQS
resource "aws_iam_role_policy" "sqs_access" {
    name = "${var.project_name}-sqs-access"
    role = aws_iam_role.ec2_role.id
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Action = [
                "sqs:ReceiveMessage", 
                "sqs:DeleteMessage"
            ]
            Resource = var.sqs_queue_arn
        }]
    })
}

resource "aws_iam_role_policy_attachment" "ssm" {
    role = aws_iam_role.ec2_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "parameter_store_access" {
    name = "${var.project_name}-${var.environment}-parameter-store-access"
    role = aws_iam_role.ec2_role.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Effect = "Allow"
            Action = [
                "ssm:PutParameter",
                "ssm:GetParameter",
                "ssm:GetParameters"
            ]
            Resource = "arn:aws:ssm:eu-west-2:463470963000:parameter/${var.project_name}-${var.environment}/*"
        }
        ]
    })
}

# EC2 Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
    name = "${var.project_name}-${var.environment}-ec2-profile"
    role = aws_iam_role.ec2_role.name
}

