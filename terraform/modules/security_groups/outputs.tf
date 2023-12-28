output "monitoring_sg_id" {
  value = aws_security_group.monitoring_sg.id
}

output "rds_postgres_sg_id" {
  value = aws_security_group.rds_postgres_sg.id
}