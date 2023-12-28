variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "common_tags" {
  description = "Common tags for all resources in the module"
  type        = map(string)
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

variable "aws_region" {
  description = "AWS region where the EKS cluster is deployed"
  type        = string
}
