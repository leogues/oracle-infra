variable "compartment_ocid" {
  description = "Compartment for the VM"
  type        = string
}

variable "name" {
  description = "Instance display name"
  type        = string
}

variable "vcn_id" {
  description = "VCN OCID"
  type        = string
}

variable "subnet_id" {
  description = "Private subnet OCID where the VM will be created"
  type        = string
}

variable "availability_domain" {
  description = "Availability domain name"
  type        = string
}

variable "ocpus" {
  description = "ARM A1.Flex OCPUs"
  type        = number
  default     = 2
}

variable "memory_in_gbs" {
  description = "Memory in GB"
  type        = number
  default     = 12
}

variable "boot_volume_size_in_gbs" {
  description = "Boot volume size in GB"
  type        = number
  default     = 100
}

variable "ssh_public_key" {
  description = "SSH public key authorized for the ubuntu user"
  type        = string
}

variable "user_data" {
  description = "Cloud-init user data (raw YAML; module base64-encodes)"
  type        = string
}

variable "tags" {
  description = "Freeform tags"
  type        = map(string)
  default     = {}
}
