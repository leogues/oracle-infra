terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

resource "random_password" "k3s_token" {
  count   = var.k3s_token == "" ? 1 : 0
  length  = 48
  special = false
}

locals {
  k3s_token = var.k3s_token != "" ? var.k3s_token : random_password.k3s_token[0].result

  user_data = templatefile("${path.module}/cloud-init/k3s-server.yaml", {
    k3s_token               = local.k3s_token
    cloudflare_tunnel_token = var.cloudflare_tunnel_token
    compartment_ocid        = var.compartment_ocid
    vcn_id                  = var.vcn_id
    ccm_lb_subnet_id        = var.ccm_lb_subnet_id
    ccm_version             = var.ccm_version
  })
}

module "vm" {
  source = "../compute-common"

  compartment_ocid        = var.compartment_ocid
  name                    = var.name
  vcn_id                  = var.vcn_id
  subnet_id               = var.subnet_id
  availability_domain     = var.availability_domain
  ocpus                   = var.ocpus
  memory_in_gbs           = var.memory_in_gbs
  boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  ssh_public_key          = var.ssh_public_key
  user_data               = local.user_data
  tags                    = var.tags
}
