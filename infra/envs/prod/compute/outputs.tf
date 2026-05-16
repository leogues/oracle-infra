output "compute" {
  description = "Aggregated compute outputs consumed by downstream layers via terraform_remote_state."
  value = {
    server = {
      instance_id = module.server.instance_id
      private_ip  = module.server.private_ip
      nsg_id      = module.server.nsg_id
      server_url  = module.server.server_url
    }

    workers = {
      for k, m in module.worker : k => {
        instance_id = m.instance_id
        private_ip  = m.private_ip
        nsg_id      = m.nsg_id
      }
    }
  }
}

output "k3s_token" {
  value     = module.server.k3s_token
  sensitive = true
}
