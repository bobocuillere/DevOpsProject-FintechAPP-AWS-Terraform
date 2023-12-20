resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "db_credentials-${var.db_name}"
  recovery_window_in_days = 0

  tags = merge(
    var.common_tags,
    {
      "Name" = "fintech-db-credentials"
    }
  )
}

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "_%#"
}


resource "random_string" "db_username" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = random_string.db_username.result
    password = random_password.db_password.result
  })

}

# resource "aws_security_group" "rds_sg" {
#   name        = "fintech-rds-sg"
#   description = "Security group for Fintech RDS instance"
#   vpc_id      = var.vpc_id

#   tags = merge(
#     var.common_tags,
#     {
#       "Name" = "fintech-rds-sg"
#     }
#   )
# }

# resource "aws_security_group_rule" "allow_from_eks" {
#   type              = "ingress"
#   from_port         = 0
#   to_port           = 65535
#   protocol          = "-1"
#   security_group_id = aws_security_group.rds_sg.id
#   source_security_group_id = var.eks_node_group_sg_id
  

# }


resource "aws_db_instance" "default" {
  allocated_storage    = var.db_allocated_storage
  storage_type         = var.db_storage_type
  engine               = var.db_engine
  engine_version       = var.db_engine_version
  instance_class       = var.db_instance_class
  identifier           = var.db_instance_identifier
  db_name              = var.db_name
  username             = jsondecode(aws_secretsmanager_secret_version.db_credentials.secret_string)["username"]
  password             = jsondecode(aws_secretsmanager_secret_version.db_credentials.secret_string)["password"]
  parameter_group_name = aws_db_parameter_group.default.name
  db_subnet_group_name = aws_db_subnet_group.default.name
  #   vpc_security_group_ids = var.vpc_security_group_ids
#   vpc_security_group_ids = [aws_security_group.rds_sg.id]

  multi_az                = var.db_multi_az
  port                    = var.db_port
  skip_final_snapshot     = true
  backup_retention_period = 0

  tags = merge(
    var.common_tags,
    {
      "Name" = "fintech-rds"
    }
  )
}

resource "aws_db_parameter_group" "default" {
  name   = "param-group-${var.db_name}"
  family = "postgres12"

}

resource "aws_db_subnet_group" "default" {
  name       = "subnet-group-${var.db_name}"
  subnet_ids = var.subnet_ids
}
