# VPC
resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
        Name = "${var.project_name}-${var.environment}-vpc"
        Environment = var.environment
        Project = var.project_name
    }
}

# IGW
resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "${var.project_name}-${var.environment}-igw"
        Environment = var.environment
        Project = var.project_name
    }
}

# Public Subnets
resource "aws_subnet" "public" {
    count = length(var.public_subnet_cidrs)
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_cidrs[count.index]
    availability_zone = data.aws_availability_zones.available.names[count.index]

    tags = {
        Name = "${var.project_name}-${var.environment}-public-${count.index + 1}"
        Environment = var.environment
        Project = var.project_name
    }
}

# Private Subnets
resource "aws_subnet" "private" {
    count = length(var.private_subnet_cidrs)
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_subnet_cidrs[count.index]
    availability_zone = data.aws_availability_zones.available.names[count.index]

    tags = {
        Name = "${var.project_name}-${var.environment}-private-${count.index + 1}"
        Environment = var.environment
        Project = var.project_name
    }
}

# Public Route Table
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }

    tags = {
        Name = "${var.project_name}-${var.environment}-public-rt"
        Environment = var.environment
        Project = var.project_name
    }
}

# Public Route Table Association with Public Subnets
resource "aws_route_table_association" "public" {
    count = length(var.public_subnet_cidrs)
    subnet_id = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.public.id
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
    domain = "vpc"
    count = length(var.public_subnet_cidrs)

    tags = {
        Name = "${var.project_name}-${var.environment}-nat-eip"
        Environment = var.environment
        Project = var.project_name
    }

    depends_on = [ aws_internet_gateway.main ]
}

# NAT Gateway
resource "aws_nat_gateway" "main" {
    count = length(var.public_subnet_cidrs)
    allocation_id = aws_eip.nat[count.index].id
    subnet_id = aws_subnet.public[count.index].id
    tags = {
        Name = "${var.project_name}-${var.environment}-nat"
        Environment = var.environment
        Project = var.project_name
    }

    depends_on = [aws_internet_gateway.main]
}

# Add private route table per AZ for private subnets
resource "aws_route_table" "private" {
    count = length(var.private_subnet_cidrs)
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.main[count.index].id
    }

    tags = {
        Name = "${var.project_name}-${var.environment}-private-rt"
        Environment = var.environment
        Project = var.project_name
    }
}

# Private Route Table Association with Private Subnets
resource "aws_route_table_association" "private" {
    count = length(var.private_subnet_cidrs)
    subnet_id = aws_subnet.private[count.index].id
    route_table_id = aws_route_table.private[count.index].id
}

data "aws_availability_zones" "available" {
    state = "available"
}

# VPC Endpoints
resource "aws_vpc_endpoint" "ssm" {
    vpc_id = aws_vpc.main.id
    service_name = "com.amazonaws.${var.aws_region}.ssm"
    vpc_endpoint_type = "Interface"
    subnet_ids = aws_subnet.private[*].id
    security_group_ids = [aws_security_group.vpc_endpoints.id]
}

resource "aws_vpc_endpoint" "ssmmessages" {
    vpc_id = aws_vpc.main.id
    service_name = "com.amazonaws.${var.aws_region}.ssmmessages"
    vpc_endpoint_type = "Interface"
    subnet_ids = aws_subnet.private[*].id
    security_group_ids = [aws_security_group.vpc_endpoints.id]
}

resource "aws_vpc_endpoint" "ec2messages" {
    vpc_id = aws_vpc.main.id
    service_name = "com.amazonaws.${var.aws_region}.ec2messages"
    vpc_endpoint_type = "Interface"
    subnet_ids = aws_subnet.private[*].id
    security_group_ids = [aws_security_group.vpc_endpoints.id]
}

# Security Group for VPC Endpoints
resource "aws_security_group" "vpc_endpoints" {
    name = "${var.project_name}-${var.environment}-vpce-sg"
    description = "Security group for VPC endpoints"
    vpc_id = aws_vpc.main.id

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        security_groups = [var.elk_sg_id]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.project_name}-${var.environment}-vpce-sg"
        Environment = var.environment
        Project = var.project_name
    }
}