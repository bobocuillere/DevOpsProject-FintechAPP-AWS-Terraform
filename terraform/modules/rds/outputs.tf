output "db_instance_endpoint" {
  value = aws_db_instance.default.endpoint
}

output "db_name" {
  value = aws_db_instance.default.db_name
}


output "secret_arn" {
  value = aws_secretsmanager_secret.db_credentials.arn
}

# output "rds_security_group_id" {
#   value = aws_security_group.rds_sg.id
# }
