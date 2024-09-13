locals {
  cluster_name = "argo"
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name                             = local.cluster_name
  cluster_version                          = "1.30"
  enable_cluster_creator_admin_permissions = true

  vpc_id                         = aws_vpc.eks_vpc.id
  subnet_ids                     = concat(aws_subnet.public_subnet[*].id, aws_subnet.private_subnet[*].id)
  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  eks_managed_node_groups = {
    argo-node-group = {
      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"

      subnet_ids = aws_subnet.private_subnet[*].id

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }
  }

  access_entries = {
    admins = {
      principal_arn = "arn:aws:iam::571017864222:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess12hr_b3ba96c04a8d56a0"

      policy_associations = {
        admins = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
}

module "lb_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                              = "${module.eks.cluster_name}_eks_lb"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "helm_release" "alb-controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "region"
    value = "us-west-2"
  }

  set {
    name  = "vpcId"
    value = aws_vpc.eks_vpc.id
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.lb_role.iam_role_arn
  }

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  values           = [file("argocd-values.yml")]
}
