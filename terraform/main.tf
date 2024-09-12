resource "aws_iam_role" "cluster_role" {
  for_each = toset(["eks", "ec2"])

  name = "${each.value}ClusterRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "${each.value}.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_policy" {
  for_each = toset(["AmazonEKSClusterPolicy", "AmazonEKSServicePolicy"])

  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
  role       = aws_iam_role.cluster_role["eks"].name
}

resource "aws_iam_role_policy_attachment" "ec2_policy" {
  for_each = toset(["AmazonEKSWorkerNodePolicy", "AmazonEKS_CNI_Policy", "AmazonEC2ContainerRegistryReadOnly"])

  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
  role       = aws_iam_role.cluster_role["ec2"].name
}

resource "aws_eks_cluster" "argo" {
  name     = "argo"
  role_arn = aws_iam_role.cluster_role["eks"].arn

  vpc_config {
    subnet_ids             = concat(aws_subnet.public_subnet[*].id, aws_subnet.private_subnet[*].id)
    endpoint_public_access = true
  }
}

resource "aws_eks_node_group" "argo" {
  cluster_name    = aws_eks_cluster.argo.name
  node_group_name = "argo-node-group"
  node_role_arn   = aws_iam_role.cluster_role["ec2"].arn
  subnet_ids      = aws_subnet.private_subnet[*].id

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.medium"]
}

data "aws_eks_cluster_auth" "argo" {
  name = aws_eks_cluster.argo.name
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true

  values = [
    <<EOF
server:
  service:
    type: LoadBalancer
  EOF
  ]
}