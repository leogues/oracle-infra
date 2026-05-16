terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

locals {
  user_data = templatefile("${path.module}/cloud-init/k3s-worker.yaml", {
    k3s_token  = var.k3s_token
    server_url = var.server_url
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
