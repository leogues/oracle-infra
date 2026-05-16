terraform {
  cloud {
    organization = "Harus"
    workspaces {
      name = "harus-infra-prod-k8s-helm"
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
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.60"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "~> 2.2"
    }
  }
}
