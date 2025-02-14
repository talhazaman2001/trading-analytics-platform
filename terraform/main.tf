module "vpc" {
    source = "./modules/vpc"

    vpc_cidr = var.vpc_cidr
    public_subnet_cidrs = var.public_subnet_cidrs
    private_subnet_cidrs = var.private_subnet_cidrs
    environment = var.environment 
    project_name = var.project_name
    elk_sg_id = module.ec2.elk_sg_id
}

module "s3" {
    source = "./modules/s3"

    environment = var.environment
    project_name = var.project_name
}

module "iam" {
    source = "./modules/iam"

    environment = var.environment
    project_name = var.project_name 
    s3_bucket_arn = module.s3.s3_bucket_arn
    sqs_queue_arn = module.s3.sqs_queue_arn
}

module "ec2" {
    source = "./modules/ec2"

    vpc_id = module.vpc.vpc_id
    public_subnet_ids = module.vpc.public_subnet_ids 
    private_subnet_ids = module.vpc.private_subnet_ids
    instance_type = var.instance_type
    environment = var.environment 
    project_name = var.project_name
    iam_instance_profile = module.iam.instance_profile_name
    target_group_arn = module.alb.target_group_arn
    s3_sqs_queue_url = module.s3.s3_sqs_queue_url
    aws_region = var.aws_region
}

module "alb" {
    source = "./modules/alb"

    project_name  = var.project_name
    environment  = var.environment
    vpc_id = module.vpc.vpc_id
    public_subnet_ids = module.vpc.public_subnet_ids
}




