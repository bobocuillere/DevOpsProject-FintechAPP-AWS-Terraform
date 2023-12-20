output "eks_worker_sg_id" {
  description = "Security group ID for EKS workers."
  value       = aws_security_group.eks_worker_sg.id
}

output "rds_sg_id" {
  description = "Security group ID for RDS."
  value       = aws_security_group.rds_sg.id
}

output "web_sg_id" {
  description = "Security group ID for web access."
  value       = aws_security_group.web_sg.id
}
