variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets, keyed by AZ"
  type        = map(string)
}

variable "availability_zones" {
  description = "List of Availability Zones"
  type        = list(string)
}

variable "node_group_desired_size" {
  description = "The desired size of the node group"
  type        = number
}

variable "node_group_max_size" {
  description = "The maximum size of the node group"
  type        = number
}

variable "node_group_min_size" {
  description = "The minimum size of the node group"
  type        = number
}

variable "node_group_instance_types" {
  description = "List of instance types for the node group"
  type        = list(string)
}

variable "db_instance_class" {
  description = "The instance type of the RDS instance."
  type        = string
}

variable "db_allocated_storage" {
  description = "The allocated storage in gigabytes."
  type        = number
}

variable "db_name" {
  description = "The name of the database to create when the DB instance is created."
  type        = string
}

variable "db_instance_identifier" {
  description = "The DB instance identifier."
  type        = string
}

variable "db_multi_az" {
  description = "Specifies if the RDS instance is multi-AZ."
  type        = bool
}

variable "db_storage_type" {
  description = "Specifies the storage type associated with DB instance."
  type        = string
}

variable "db_engine" {
  description = "The database engine to use."
  type        = string
}

variable "db_engine_version" {
  description = "The engine version to use."
  type        = string
}

variable "db_port" {
  description = "The port on which the DB accepts connections."
  type        = number
}

# ... other variables ...
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ebs_volume_size" {
  description = "Size of the EBS volume in GB"
  type        = number

}

variable "key_pair_name" {
  description = "Name of the existing AWS key pair"
  type        = string
}