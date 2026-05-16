terraform {
  cloud {
    organization = "Harus"
    workspaces {
      name = "harus-prod-k8s-helm"
    }
  }

  required_version = ">= 1.5"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.1"
    }
    kustomization = {
      source  = "kbst/kustomization"
      version = "~> 0.9"
    }
  }
}
