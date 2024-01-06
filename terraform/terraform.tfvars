aws_region = "eu-central-1"
vpc_cidr   = "10.0.0.0/16"
public_subnet_cidrs = {
  "eu-central-1a" = "10.0.1.0/24"
  "eu-central-1b" = "10.0.2.0/24"
}
availability_zones = ["eu-central-1a", "eu-central-1b"]

node_group_desired_size   = 3
node_group_min_size       = 3
node_group_max_size       = 3
node_group_instance_types = ["t3.medium"]

db_instance_class      = "db.t2.micro"
db_allocated_storage   = 20
db_name                = "fintech"
db_instance_identifier = "postgres-fintech"
db_multi_az            = false
db_storage_type        = "gp2"
db_engine              = "postgres"
db_engine_version      = "12.17"
db_port                = 5432

ebs_volume_size = 20
instance_type   = "t2.micro"
key_pair_name   = "fintech-monitoring"