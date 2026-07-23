module "vpc" {
  source               = "../../modules/vpc"
  project_name         = var.project_name
  public_subnet_cidrs  = ["10.0.1.0/24"]
  private_subnet_cidrs = ["10.0.2.0/24"]
  azs                  = ["us-east-1a"]
}

module "s3" {
  source       = "../../modules/s3"
  project_name = var.project_name
}

module "ec2" {
  source     = "../../modules/ec2"
  project_name = var.project_name
  vpc_id     = module.vpc.vpc_id
  subnet_id  = module.vpc.public_subnet_ids[0]
}

module "alb" {
  source            = "../../modules/alb"
  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  security_group_id = module.ec2.security_group_id
  instance_ids       = module.ec2.instance_ids
}

module "rds" {
  source                 = "../../modules/rds"
  project_name           = var.project_name
  vpc_id                 = module.vpc.vpc_id
  private_subnet_ids     = module.vpc.private_subnet_ids
  web_security_group_id  = module.ec2.security_group_id
  db_username            = var.db_username
  db_password            = var.db_password
}
