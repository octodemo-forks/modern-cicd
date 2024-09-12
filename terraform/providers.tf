# terraform {
#   cloud {
#     organization = "jeffwhite"

#     workspaces {
#       name = "cidemo"
#     }
#   }
# }

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.argo.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.argo.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.argo.token
  }
}

provider "aws" {
  region  = "us-west-2"
  profile = "evhc"
}