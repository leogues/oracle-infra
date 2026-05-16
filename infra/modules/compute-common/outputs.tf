output "instance_id" {
  description = "Instance OCID"
  value       = oci_core_instance.this.id
}

output "private_ip" {
  description = "VM private IP"
  value       = oci_core_instance.this.private_ip
}

output "nsg_id" {
  description = "NSG attached to the VM"
  value       = oci_core_network_security_group.vm.id
}
