provider "aws" {
  region = "eu-north-1"
}

terraform {
  backend "s3" {
    bucket         = "mkvisualsstudio-state-bucket"    # Replace with your S3 bucket name
    key            = "mk/visualsstudio/terraform.tfstate" # The path within the bucket to store the state file. You can structure it according to your project.
    region         = "eu-north-1"                    # Region where the S3 bucket is located
    dynamodb_table = "mkvstudio-terraform-lock-table"         # DynamoDB table for state locking
    encrypt        = true                           # Encrypt state file using S3 default encryption
  }
}

module "main-vpc" {
  source = "./vpc"
  vpc_cidr_block = var.vpc_cidr_block
  tags = local.project_tags
  frontend_cidr_block = var.frontend_cidr_block
  availability_zone = var.availability_zone
  backend_cidr_block = var.backend_cidr_block
}

module "alb" {
  source = "./alb"
  frontend-subnet-az1a = module.main-vpc.frontend-subnet-az1a
  frontend-subnet-az1b = module.main-vpc.frontend-subnet-az1b
  tags = local.project_tags
  ssl_policy = var.ssl_policy
  certificate_arn = var.certificate_arn
  vpc_id = module.main-vpc.vpc_id

}

module "aws_autoscaling_group" {
  source = "./auto-scaling"
  key_name = var.key_name
  target_group_arn = module.alb.target_group_arn
  image_id = var.image_id
  alb_sg_id = module.alb.alb_sg_id
  frontend-subnet-az1a = module.main-vpc.frontend-subnet-az1a
  frontend-subnet-az1b = module.main-vpc.frontend-subnet-az1b
  instance_type = var.instance_type
  vpc_id = module.main-vpc.vpc_id
}
module "route53" {
  source = "./route53"
  zone_id = var.zone_id
  alb_dns_name = module.alb.alb_dns_name
  dns_name = var.dns_name
  alb_zone_id = module.alb.alb_zone_id

}

module "ec2" {
  source = "./ec2"
  vpc_id = module.main-vpc.vpc_id
  image_id = var.image_id
  instance_type = var.instance_type
  tags = local.project_tags
  key_name = var.key_name
  frontend-subnet-az1a = module.main-vpc.frontend-subnet-az1a
  backend-subnet-az1b = module.main-vpc.backend-subnet-az1b
  backend-subnet-az1a = module.main-vpc.backend-subnet-az1a
}

module "rds" {
  source = "./rds"
  vpc_id = module.main-vpc.vpc_id
  password = var.password
  vpc_cidr_block = module.main-vpc.vpc_cidr_block
  tags = local.project_tags
  db-subnet-az1a-id = module.main-vpc.db-subnet-az1a-id
  db-subnet-az1b-id = module.main-vpc.db-subnet-az1b-id
  instance_class = var.instance_class
  username = var.username
  engine_version = var.engine_version
}