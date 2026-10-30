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
  description = "Additional k3s workers. The server uses the full Always Free allowance of 2 OCPUs / 12 GB."
  type        = number
  default     = 0

  validation {
    condition     = var.worker_size == 0
    error_message = "Keep worker_size = 0: the 2 OCPU / 12 GB server already consumes the current Ampere A1 Always Free allowance."
  }
}
