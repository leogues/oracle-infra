terraform {
  cloud {
    organization = "Harus"
    workspaces {
      name = "harus-infra-prod-k8s-namespaces"
    }
  }

  required_version = ">= 1.5"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}
