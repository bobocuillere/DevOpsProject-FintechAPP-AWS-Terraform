# resource "aws_security_group" "eks_worker_sg" {
#   name   = "eks-worker-sg"
#   vpc_id = var.vpc_id

#   # Allow EKS control plane to communicate with worker nodes
#   ingress {
#     from_port   = 1025
#     to_port     = 65535
#     protocol    = "tcp"
#     cidr_blocks = [var.eks_cluster_cidr]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = var.common_tags
# }

resource "aws_security_group" "rds_sg" {
  name   = "rds-sg"
  vpc_id = var.vpc_id

  # Allow application pods to access RDS
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [ " 0.0.0.0/0" ]
    # security_groups = [aws_security_group.eks_worker_sg.id]
  }

#   tags = var.common_tags
}

# resource "aws_security_group" "web_sg" {
#   name   = "web-sg"
#   vpc_id = var.vpc_id

#   # Allow HTTP/HTTPS traffic
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = var.common_tags
# }
