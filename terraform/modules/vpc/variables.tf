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

variable "common_tags" {
  description = "Common tags for all resources in the module"
  type        = map(string)
}
