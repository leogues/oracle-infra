terraform {
  cloud {
    organization = "Harus"
    workspaces {
      name = "harus-infra-prod-k8s-secrets"
    }
  }

  required_version = ">= 1.5"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 0.7"
    }
  }
}
