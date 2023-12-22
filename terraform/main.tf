locals {
  common_tags = {
    Project     = "Fintech Cloud Project"
    ManagedBy   = "Terraform"
    Department  = "Finance Technology"
    Application = "Fintech App"
    Owner       = "Sophnel"
  }
}

module "vpc" {
  source              = "./modules/vpc"
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  availability_zones  = var.availability_zones
  common_tags         = local.common_tags
}

resource "aws_ecr_repository" "fintech_ecr_repo" {
  name                 = "fintech-app-repo"
  image_tag_mutability = "MUTABLE"

    tags = merge(
    local.common_tags,
    {
      "Name" = "fintech-ecr"
    }
  )
}

module "eks" {
  source                    = "./modules/eks"
  aws_region                = var.aws_region
  subnet_ids                = module.vpc.public_subnet_ids
  common_tags               = local.common_tags
  node_group_desired_size   = var.node_group_desired_size
  node_group_max_size       = var.node_group_max_size
  node_group_min_size       = var.node_group_min_size
  node_group_instance_types = var.node_group_instance_types
}

module "rds" {
  source                 = "./modules/rds"
  common_tags            = local.common_tags
  vpc_id                 = module.vpc.vpc_id
  db_instance_class      = var.db_instance_class
  db_allocated_storage   = var.db_allocated_storage
  db_name                = var.db_name
  db_instance_identifier = var.db_instance_identifier
  subnet_ids             = module.vpc.public_subnet_ids
#   eks_node_group_sg_id = module.eks.eks_node_group_security_group_id

  #   vpc_security_group_ids  = module.vpc.security_group_ids
  db_multi_az       = var.db_multi_az
  db_storage_type   = var.db_storage_type
  db_engine         = var.db_engine
  db_engine_version = var.db_engine_version
  db_port           = var.db_port

}

# ... other module calls ...
