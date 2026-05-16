terraform {
  cloud {
    organization = "Harus"
    workspaces {
      name = "harus-prod-compute"
    }
  }

  required_version = ">= 1.5"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 8.13"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}
