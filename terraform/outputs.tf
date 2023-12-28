output "configure_kubectl" {
  value = module.eks.kubeconfig_command
}

output "aws_region" {
  value = var.aws_region
}

output "ecr_repository_url" {
  value = aws_ecr_repository.fintech_ecr_repo.repository_url
}

output "rds_instance_endpoint" {
  value = module.rds.db_instance_endpoint
}

output "rds_db_name" {
  value = module.rds.db_name
}

output "rds_secret_arn" {
  value = module.rds.secret_arn
}

output "grafana_instance_ip" {
  value = module.monitoring_ec2.grafana_instance_ip
}

output "prometheus_instance_ip" {
  value = module.monitoring_ec2.prometheus_instance_ip
}

output "eks_cluster_sg_id" {
  value = module.eks.eks_cluster_sg_id
}