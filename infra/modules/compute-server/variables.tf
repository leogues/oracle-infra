variable "compartment_ocid" {
  type = string
}

variable "name" {
  type = string
}

variable "vcn_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "availability_domain" {
  type = string
}

variable "ocpus" {
  type    = number
  default = 2
}

variable "memory_in_gbs" {
  type    = number
  default = 12
}

variable "boot_volume_size_in_gbs" {
  type    = number
  default = 100
}

variable "ssh_public_key" {
  type = string
}

variable "cloudflare_tunnel_token" {
  type      = string
  sensitive = true
}

variable "k3s_token" {
  description = "k3s shared secret. Random if empty."
  type        = string
  default     = ""
  sensitive   = true
}

variable "ccm_lb_subnet_id" {
  description = "Public subnet OCID used by OCI CCM as loadBalancer.subnet1"
  type        = string
}

variable "ccm_version" {
  description = "Oracle OCI Cloud Controller Manager release tag (eg v1.34.0)"
  type        = string
  default     = "v1.34.0"
}

variable "tags" {
  type    = map(string)
  default = {}
}
