output "dynamic_group_name" {
  description = "Dynamic group name (used in policies referencing CCM permissions)"
  value       = oci_identity_dynamic_group.k3s_nodes.name
}

output "dynamic_group_id" {
  value = oci_identity_dynamic_group.k3s_nodes.id
}

output "policy_id" {
  value = oci_identity_policy.ccm.id
}
