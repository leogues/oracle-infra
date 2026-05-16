terraform {
  cloud {
    organization = "Harus"
    workspaces {
      name = "harus-prod-k8s-secrets"
    }
  }

  required_version = ">= 1.5"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "~> 2.2"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 0.7"
    }
  }
}
