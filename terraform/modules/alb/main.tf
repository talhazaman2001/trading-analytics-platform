# ALB
resource "aws_lb" "elk" {
    name = "${var.project_name}-${var.environment}-alb"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.alb.id]
    subnets = var.public_subnet_ids

    tags = {
        Name = "${var.project_name}-${var.environment}-alb"
        Environment = var.environment
        Project = var.project_name
    }
}

# ALB Listener
resource "aws_lb_listener" "kibana" {
    load_balancer_arn = aws_lb.elk.arn 
    port = "80"
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.kibana.arn 
    }
}

# ALB Target Group
resource "aws_lb_target_group" "kibana" {
    name = "${var.project_name}-${var.environment}-kibana"
    port = 5601
    protocol = "HTTP"
    vpc_id = var.vpc_id

    health_check {
        path = "/api/status"
        healthy_threshold = 2
        unhealthy_threshold = 10
    }
}

# ALB Security Group
resource "aws_security_group" "alb" {
    name = "${var.project_name}-${var.environment}-alb-sg"
    description = "Security group for ALB"
    vpc_id = var.vpc_id

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

