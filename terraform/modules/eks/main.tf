resource "aws_iam_role" "eks_cluster_role" {
  name = "fintech_eks_cluster_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# data "aws_eks_node_group" "node_group" {
#   cluster_name    = aws_eks_cluster.fintech_eks.name
#   node_group_name = aws_eks_node_group.fintech_eks_nodes.node_group_name
# #   resources {
# #     remote_access_security_group_id = remote_access_security_group_id
# #   }
   
# }

# Fetch the EKS Node Group Security Group based on tags
# data "aws_security_group" "eks_node_group_sg" {
#   filter {
#     name   = "tag:eks:cluster-name"
#     values = [aws_eks_cluster.fintech_eks.name]
#   }
# }



resource "aws_eks_cluster" "fintech_eks" {
  name     = "fintech-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_service_policy
  ]

  tags = var.common_tags
}

# Node Group configuration will be here
resource "aws_eks_node_group" "fintech_eks_nodes" {
  cluster_name    = aws_eks_cluster.fintech_eks.name
  node_group_name = "fintech-eks-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.subnet_ids
  
  scaling_config {
    desired_size = var.node_group_desired_size
    max_size     = var.node_group_max_size
    min_size     = var.node_group_min_size
  }

  instance_types = var.node_group_instance_types

  tags = merge(
    var.common_tags,
    {
      "Name" = "fintech-eks-node-group"
    }
  )
}

resource "aws_iam_role" "eks_node_role" {
  name = "fintech_eks_node_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "eks_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_ec2_container_registry_full" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  role       = aws_iam_role.eks_node_role.name
}
