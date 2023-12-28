variable "common_tags" {
  description = "Common tags for all resources in the module"
  type        = map(string)
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

variable "subnet_ids" {
  description = "List of subnet IDs for the RDS instance."
  type        = list(string)
}

variable "vpc_id" {
  description = "The VPC ID where the RDS instance is deployed"
  type        = string
}

variable "rds_sg_id" {
  description = "Security Group ID of the EKS node group"
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
