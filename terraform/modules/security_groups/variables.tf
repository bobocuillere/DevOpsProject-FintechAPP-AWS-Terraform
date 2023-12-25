variable "vpc_id" {
  description = "VPC ID where the security groups will be created."
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources."
  type        = map(string)
}
