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

# data "aws_security_group" "eks_node_group_sg" {
#   tags = {
#     "Name" = aws_eks_cluster.fintech_eks.name
#     # "eks:nodegroup-name" = aws_eks_node_group.fintech_eks_nodes.node_group_name
#   }
# }

# output "node_group_security_group_id" {
#   value = data.aws_security_group.eks_node_group_sg.id
# }
# Output the Security Group ID
# output "eks_node_group_security_group_id" {
#   value = data.aws_security_group.eks_node_group_sg.id
# }