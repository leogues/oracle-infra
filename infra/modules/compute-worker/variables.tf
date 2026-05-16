variable "compartment_ocid" {
  type = string
}

variable "name_prefix" {
  description = "Resource name prefix — '{org}-{env}-compute'"
  type        = string
}

variable "instance_suffix" {
  description = "Per-instance suffix. Example: 'k3s-worker-01'."
  type        = string
}

variable "vcn_id" {
  type = string
}

variable "vcn_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_id" {
  type = string
}

variable "availability_domain" {
  type = string
}

variable "fault_domain" {
  type    = string
  default = null
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

variable "freeform_tags" {
  type    = map(string)
  default = {}
}
