output "id" {
  description = "VCN OCID"
  value       = oci_core_vcn.this.id
}

output "cidr" {
  description = "VCN CIDR block"
  value       = var.vcn_cidr
}

output "public_subnet_ids" {
  description = "Public subnet OCIDs"
  value       = oci_core_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet OCIDs"
  value       = oci_core_subnet.private[*].id
}

output "availability_domains" {
  description = "Availability domain names"
  value       = [for ad in data.oci_identity_availability_domains.ads.availability_domains : ad.name]
}

output "internet_gateway_id" {
  value = oci_core_internet_gateway.igw.id
}

output "nat_gateway_id" {
  value = oci_core_nat_gateway.nat.id
}

output "service_gateway_id" {
  value = oci_core_service_gateway.sgw.id
}
