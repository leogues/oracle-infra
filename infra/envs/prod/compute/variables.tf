variable "tenancy_ocid" { type = string }
variable "user_ocid" { type = string }
variable "fingerprint" { type = string }
variable "private_key" {
  type      = string
  sensitive = true
}
variable "region" {
  type    = string
  default = "sa-vinhedo-1"
}
variable "compartment_ocid" { type = string }

variable "ssh_public_key" { type = string }

variable "cloudflare_tunnel_token" {
  type      = string
  sensitive = true
}

variable "worker_size" {
  description = "Number of k3s worker nodes"
  type        = number
  default     = 1
}
