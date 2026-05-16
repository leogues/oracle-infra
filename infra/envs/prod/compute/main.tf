provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  user_ocid    = var.user_ocid
  fingerprint  = var.fingerprint
  private_key  = var.private_key
  region       = var.region
}

module "ctx" {
  source = "../../../modules/env-context"

  org   = "harus"
  env   = "prod"
  layer = "compute"
}

data "terraform_remote_state" "net" {
  backend = "remote"
  config = {
    organization = "Harus"
    workspaces   = { name = "harus-prod-net" }
  }
}

locals {
  net = data.terraform_remote_state.net.outputs.network

  server_freeform = merge(module.ctx.freeform_tags, { role = "k3s-server" })
  worker_freeform = merge(module.ctx.freeform_tags, { role = "k3s-worker" })

  worker_nodes = { for i in range(var.worker_size) : format("k3s-worker-%02d", i + 1) => i }

  primary_private_subnet = local.net.subnets.private["p1"]
  primary_public_subnet  = local.net.subnets.public["p1"]
  primary_ad             = local.net.availability_domains[0]
}

module "server" {
  source = "../../../modules/compute-server"

  compartment_ocid = var.compartment_ocid

  name_prefix     = module.ctx.name_prefix
  instance_suffix = "k3s-server-01"

  vcn_id              = local.net.vcn_id
  vcn_cidr            = local.net.vcn_cidr
  subnet_id           = local.primary_private_subnet
  availability_domain = local.primary_ad

  ocpus                   = 2
  memory_in_gbs           = 12
  boot_volume_size_in_gbs = 100

  ssh_public_key          = var.ssh_public_key
  cloudflare_tunnel_token = var.cloudflare_tunnel_token

  ccm_lb_subnet_id = local.primary_public_subnet

  freeform_tags = local.server_freeform
}

module "worker" {
  source   = "../../../modules/compute-worker"
  for_each = local.worker_nodes

  compartment_ocid = var.compartment_ocid

  name_prefix     = module.ctx.name_prefix
  instance_suffix = each.key

  vcn_id              = local.net.vcn_id
  vcn_cidr            = local.net.vcn_cidr
  subnet_id           = local.primary_private_subnet
  availability_domain = local.primary_ad
  fault_domain        = "FAULT-DOMAIN-${(each.value % 3) + 1}"

  ocpus                   = 2
  memory_in_gbs           = 12
  boot_volume_size_in_gbs = 100

  ssh_public_key = var.ssh_public_key
  k3s_token      = module.server.k3s_token
  server_url     = module.server.server_url

  freeform_tags = local.worker_freeform
}
