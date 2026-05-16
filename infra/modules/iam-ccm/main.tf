terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

locals {
  dynamic_group_name = "${var.name_prefix}-dg-k3s-nodes"
  policy_name        = "${var.name_prefix}-pol-ccm"
}

resource "oci_identity_dynamic_group" "k3s_nodes" {
  compartment_id = var.tenancy_ocid
  name           = local.dynamic_group_name
  description    = "k3s nodes — instance principal auth for OCI CCM"
  matching_rule  = "ALL {instance.compartment.id = '${var.compartment_ocid}'}"
  freeform_tags  = var.freeform_tags
}

resource "oci_identity_policy" "ccm" {
  compartment_id = var.tenancy_ocid
  name           = local.policy_name
  description    = "Permissions for OCI Cloud Controller Manager via instance principal"
  freeform_tags  = var.freeform_tags

  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.k3s_nodes.name} to manage load-balancers in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.k3s_nodes.name} to use virtual-network-family in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.k3s_nodes.name} to manage instances in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.k3s_nodes.name} to read instance-family in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.k3s_nodes.name} to use security-lists in compartment id ${var.compartment_ocid}",
  ]
}
