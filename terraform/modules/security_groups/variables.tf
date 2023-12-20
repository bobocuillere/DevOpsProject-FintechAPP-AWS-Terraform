variable "vpc_id" {
  description = "VPC ID where the security groups will be created."
  type        = string
}

variable "eks_cluster_cidr" {
  description = "CIDR block for the EKS cluster."
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources."
  type        = map(string)
}
