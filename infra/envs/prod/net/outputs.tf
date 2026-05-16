output "network" {
  description = "Aggregated network outputs consumed by downstream layers via terraform_remote_state."
  value = {
    compartment_ocid = var.compartment_ocid

    vcn_id   = module.vcn.id
    vcn_cidr = module.vcn.cidr

    subnets = {
      public  = { for i, id in module.vcn.public_subnet_ids : format("p%d", i + 1) => id }
      private = { for i, id in module.vcn.private_subnet_ids : format("p%d", i + 1) => id }
    }

    availability_domains = module.vcn.availability_domains

    gateways = {
      internet = module.vcn.internet_gateway_id
      nat      = module.vcn.nat_gateway_id
      service  = module.vcn.service_gateway_id
    }
  }
}
