output "db_instance_endpoint" {
  value = aws_db_instance.default.endpoint
}

output "db_name" {
  value = aws_db_instance.default.db_name
}


output "secret_arn" {
  value = aws_secretsmanager_secret.db_credentials.arn
}

