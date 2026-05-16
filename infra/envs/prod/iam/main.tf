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
  layer = "iam"
}

module "iam_ccm" {
  source = "../../../modules/iam-ccm"

  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = var.compartment_ocid
  name_prefix      = module.ctx.name_prefix

  freeform_tags = merge(module.ctx.freeform_tags, { role = "ccm" })
}
