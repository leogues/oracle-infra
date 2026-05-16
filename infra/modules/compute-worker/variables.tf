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

variable "k3s_token" {
  type      = string
  sensitive = true
}

variable "server_url" {
  description = "k3s server URL (https://<ip>:6443)"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
