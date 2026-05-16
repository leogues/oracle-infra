terraform {
  cloud {
    organization = "Harus"
    workspaces {
      name = "harus-infra-prod-iam"
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

module "iam_ccm" {
  source = "../../../modules/iam-ccm"

  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = var.compartment_ocid

  tags = {
    project    = "harus"
    env        = "prod"
    role       = "ccm"
    managed_by = "terraform"
  }
}

output "dynamic_group_name" {
  value = module.iam_ccm.dynamic_group_name
}

output "dynamic_group_id" {
  value = module.iam_ccm.dynamic_group_id
}

output "policy_id" {
  value = module.iam_ccm.policy_id
}
