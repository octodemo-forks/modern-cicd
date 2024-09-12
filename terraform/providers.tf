terraform {
  backend "s3" {
    bucket = "terraform-state-evhc"
    key    = "cicddemo/terraform.tfstate"
    region = "us-west-2"
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", "us-west-2"]
    }
  }
}

provider "aws" {
  region = "us-west-2"
}
