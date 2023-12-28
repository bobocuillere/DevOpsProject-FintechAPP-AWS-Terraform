output "cluster_id" {
  value = aws_eks_cluster.fintech_eks.id
}

output "cluster_arn" {
  value = aws_eks_cluster.fintech_eks.arn
}

output "cluster_endpoint" {
  value = aws_eks_cluster.fintech_eks.endpoint
}

output "cluster_security_group_id" {
  value = aws_eks_cluster.fintech_eks.vpc_config[0].cluster_security_group_id
}

output "kubeconfig_command" {
  description = "Command to configure kubectl with EKS cluster"
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.fintech_eks.name} --region ${var.aws_region}"
}

output "eks_cluster_sg_id" {
  value = data.aws_eks_cluster.fintech_eks.vpc_config[0].cluster_security_group_id
}