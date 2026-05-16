terraform {
  cloud {
    organization = "Harus"
    workspaces {
      name = "harus-infra-prod-network"
    }
  }

  required_version = ">= 1.5"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 8.13"
    }
  }
}

variable "tenancy_ocid" { type = string }
variable "user_ocid" { type = string }
variable "fingerprint" { type = string }
variable "private_key" {
  type      = string
  sensitive = true
}
variable "region" {
  type    = string
  default = "sa-vinhedo-1"
}
variable "compartment_ocid" { type = string }

provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  user_ocid    = var.user_ocid
  fingerprint  = var.fingerprint
  private_key  = var.private_key
  region       = var.region
}

module "vcn" {
  source = "../../../modules/vcn"

  compartment_ocid     = var.compartment_ocid
  name                 = "harus-prod-vcn"
  vcn_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]

  tags = {
    project    = "harus"
    env        = "prod"
    role       = "network"
    managed_by = "terraform"
  }
}

output "compartment_ocid" {
  value = var.compartment_ocid
}

output "vcn_id" {
  value = module.vcn.id
}

output "public_subnet_ids" {
  value = module.vcn.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vcn.private_subnet_ids
}

output "availability_domains" {
  value = module.vcn.availability_domains
}
