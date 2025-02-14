# ELK Security Group
resource "aws_security_group" "elk" {
    name = "${var.project_name}-${var.environment}-elk-sg"
    description = "Security group for ELK stack"
    vpc_id = var.vpc_id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 5601
        to_port = 5601
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 9200
        to_port = 9200
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.project_name}-${var.environment}-elk-sg"
        Environment = var.environment
        Project = var.project_name 
    }
}

# EC2 AMI
data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    } 

    owners = ["099720109477"] 
}

# EC2 Instance
resource "aws_instance" "elk" {
    ami = data.aws_ami.ubuntu.id 
    instance_type = var.instance_type

    subnet_id = var.public_subnet_ids[0]
    vpc_security_group_ids = [aws_security_group.elk.id]
    associate_public_ip_address = true 
    iam_instance_profile = var.iam_instance_profile

    user_data = templatefile("${path.root}/templates/user_data.tpl", {
        cluster_name = "${var.project_name}-${var.environment}"
        s3_sqs_queue_url = var.s3_sqs_queue_url
        aws_region = var.aws_region
    })

    root_block_device {
        volume_size = 30 
        volume_type = "gp3"
    }

    tags = {
        Name = "${var.project_name}-${var.environment}-elk"
        Environment = var.environment
        Project = var.project_name
    }
}

# EC2 Launch Template
resource "aws_launch_template" "elk" {
    name_prefix   = "${var.project_name}-${var.environment}-lt"
    image_id = data.aws_ami.ubuntu.id
    instance_type = var.instance_type

    network_interfaces {
        associate_public_ip_address = false
        security_groups = [aws_security_group.elk.id]
    }

    iam_instance_profile {
        name = var.iam_instance_profile
    }

    user_data = base64encode(templatefile("${path.root}/templates/user_data.tpl", {
        cluster_name = "${var.project_name}-${var.environment}"
        s3_sqs_queue_url = var.s3_sqs_queue_url
        aws_region = var.aws_region
    }))

    block_device_mappings {
        device_name = "/dev/sda1"
        ebs {
            volume_size = 30
            volume_type = "gp3"
        }
    }

    tags = {
        Name  = "${var.project_name}-${var.environment}-lt"
        Environment = var.environment
        Project = var.project_name
    }
}

# Autoscaling group
resource "aws_autoscaling_group" "elk" {
    name = "${var.project_name}-${var.environment}-asg"
    desired_capacity = var.desired_capacity
    max_size = var.max_size
    min_size = var.min_size
    target_group_arns = [var.target_group_arn]
    vpc_zone_identifier = var.private_subnet_ids

    launch_template {
        id = aws_launch_template.elk.id
        version = "$Latest"
    }

    # Elasticsearch needs time to join/leave cluster
    health_check_grace_period = 300
    health_check_type = "ELB"

    dynamic "tag" {
        for_each = {
            Name = "${var.project_name}-${var.environment}-elk"
            Environment = var.environment
            Project = var.project_name
        }
        content {
            key = tag.key
            value = tag.value
            propagate_at_launch = true
        }
    }
}

# ASG policies for scaling
resource "aws_autoscaling_policy" "scale_up" {
    name = "${var.project_name}-${var.environment}-scale-up"
    scaling_adjustment = 1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    autoscaling_group_name = aws_autoscaling_group.elk.name
}

resource "aws_autoscaling_policy" "scale_down" {
    name = "${var.project_name}-${var.environment}-scale-down"
    scaling_adjustment = -1
    adjustment_type = "ChangeInCapacity"
    cooldown = 300
    autoscaling_group_name = aws_autoscaling_group.elk.name
}
