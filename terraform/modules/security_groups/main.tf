resource "aws_security_group" "monitoring_sg" {
  name        = "monitoring-sg"
  description = "Security group for Monitoring Servers (Grafana and Prometheus)"
  vpc_id      = var.vpc_id

  # Example rule: Allow all incoming traffic (Not recommended for production)
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # (Add any specific egress rules if required)

  tags = var.common_tags
}
