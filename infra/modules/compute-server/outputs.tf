output "instance_id" {
  value = module.vm.instance_id
}

output "private_ip" {
  value = module.vm.private_ip
}

output "nsg_id" {
  value = module.vm.nsg_id
}

output "k3s_token" {
  value     = local.k3s_token
  sensitive = true
}

output "server_url" {
  value = "https://${module.vm.private_ip}:6443"
}
