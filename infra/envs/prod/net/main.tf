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
  layer = "net"
}

module "vcn" {
  source = "../../../modules/vcn"

  compartment_ocid     = var.compartment_ocid
  name_prefix          = module.ctx.name_prefix
  vcn_cidr             = var.vcn_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  freeform_tags = merge(module.ctx.freeform_tags, { role = "vcn" })
}
