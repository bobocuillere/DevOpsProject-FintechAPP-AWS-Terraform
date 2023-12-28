resource "aws_security_group" "monitoring_sg" {
  name        = "monitoring-sg"
  description = "Security group for Monitoring Servers (Grafana and Prometheus)"
  vpc_id      = var.vpc_id

  ingress {
    description = "Grafana ingress"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Prometheus HTTP"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    description = "ssh ingress"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.common_tags
}

resource "aws_security_group" "eks_node_sg" {
  name        = "Eks-sg"
  description = "Security group for EKS"
  vpc_id      = var.vpc_id

  tags = var.common_tags
}

resource "aws_security_group" "rds_postgres_sg" {
  name        = "RDS-sg"
  description = "Security group for RDS"
  vpc_id      = var.vpc_id

  ingress {
    description = "Source EKS Node ingress"
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    security_groups = [ aws_security_group.eks_node_sg.id ]
  }

  tags = var.common_tags
}