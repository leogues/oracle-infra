terraform {
  cloud {
    organization = "Harus"
    workspaces {
      name = "harus-infra-prod-compute"
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
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.60"
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
variable "ssh_public_key" { type = string }
variable "cloudflare_tunnel_token" {
  type      = string
  sensitive = true
}

variable "name_prefix" {
  type    = string
  default = "harus-prod-k3s"
}

variable "worker_size" {
  description = "Number of k3s worker nodes"
  type        = number
  default     = 1
}

provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  user_ocid    = var.user_ocid
  fingerprint  = var.fingerprint
  private_key  = var.private_key
  region       = var.region
}

data "tfe_outputs" "vcn" {
  organization = "Harus"
  workspace    = "harus-infra-prod-network"
}

locals {
  common_tags = {
    project    = "harus"
    env        = "prod"
    role       = "k3s"
    managed_by = "terraform"
  }

  worker_nodes = { for i in range(var.worker_size) : format("worker-%02d", i + 1) => i }
}

module "server" {
  source = "../../../modules/compute-server"

  compartment_ocid    = var.compartment_ocid
  name                = "${var.name_prefix}-server-01"
  vcn_id              = data.tfe_outputs.vcn.values.vcn_id
  subnet_id           = data.tfe_outputs.vcn.values.private_subnet_ids[0]
  availability_domain = data.tfe_outputs.vcn.values.availability_domains[0]

  ocpus                   = 2
  memory_in_gbs           = 12
  boot_volume_size_in_gbs = 100

  ssh_public_key          = var.ssh_public_key
  cloudflare_tunnel_token = var.cloudflare_tunnel_token

  ccm_lb_subnet_id = data.tfe_outputs.vcn.values.public_subnet_ids[0]

  tags = local.common_tags
}

module "worker" {
  source   = "../../../modules/compute-worker"
  for_each = local.worker_nodes

  compartment_ocid    = var.compartment_ocid
  name                = "${var.name_prefix}-${each.key}"
  vcn_id              = data.tfe_outputs.vcn.values.vcn_id
  subnet_id           = data.tfe_outputs.vcn.values.private_subnet_ids[each.value % length(data.tfe_outputs.vcn.values.private_subnet_ids)]
  availability_domain = data.tfe_outputs.vcn.values.availability_domains[0]

  ocpus                   = 2
  memory_in_gbs           = 12
  boot_volume_size_in_gbs = 100

  ssh_public_key = var.ssh_public_key
  k3s_token      = module.server.k3s_token
  server_url     = module.server.server_url

  tags = local.common_tags
}

output "server_instance_id" {
  value = module.server.instance_id
}

output "server_private_ip" {
  value = module.server.private_ip
}

output "server_nsg_id" {
  value = module.server.nsg_id
}

output "worker_instance_ids" {
  value = { for k, m in module.worker : k => m.instance_id }
}

output "worker_private_ips" {
  value = { for k, m in module.worker : k => m.private_ip }
}

output "worker_nsg_ids" {
  value = { for k, m in module.worker : k => m.nsg_id }
}

output "k3s_token" {
  value     = module.server.k3s_token
  sensitive = true
}
