variable "compartment_ocid" {
  description = "Compartment for the VM"
  type        = string
}

variable "name_prefix" {
  description = "Resource name prefix — typically '{org}-{env}-compute' from modules/env-context"
  type        = string
}

variable "instance_suffix" {
  description = "Per-instance suffix appended after resource-kind segment. Example: 'k3s-server-01', 'k3s-worker-01'."
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

variable "fault_domain" {
  description = "Fault domain name (FAULT-DOMAIN-1/2/3). Null lets OCI choose."
  type        = string
  default     = null
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

variable "vcn_cidr" {
  description = "VCN CIDR — used for intra-VCN ingress rule"
  type        = string
  default     = "10.0.0.0/16"
}

variable "freeform_tags" {
  description = "Freeform tags applied to VM and NSG"
  type        = map(string)
  default     = {}
}
