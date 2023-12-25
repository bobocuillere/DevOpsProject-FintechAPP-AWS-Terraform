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

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "monitoring_sg_id" {
  description = "Security Group ID for monitoring instances"
  type        = string
}

# (Rest of your variables)


variable "common_tags" {
  description = "Common tags for all resources in the module"
  type        = map(string)
}