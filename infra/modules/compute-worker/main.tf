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
  name_prefix             = var.name_prefix
  instance_suffix         = var.instance_suffix
  vcn_id                  = var.vcn_id
  vcn_cidr                = var.vcn_cidr
  subnet_id               = var.subnet_id
  availability_domain     = var.availability_domain
  fault_domain            = var.fault_domain
  ocpus                   = var.ocpus
  memory_in_gbs           = var.memory_in_gbs
  boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  ssh_public_key          = var.ssh_public_key
  user_data               = local.user_data

  freeform_tags = var.freeform_tags
}
