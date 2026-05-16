variable "compartment_ocid" {
  description = "Compartment where the VCN is created"
  type        = string
}

variable "name_prefix" {
  description = "Resource name prefix — typically '{org}-{env}-net' from modules/env-context"
  type        = string
}

variable "dns_label" {
  description = "VCN dns_label (max 15 alphanumeric, must start with letter)"
  type        = string
  default     = "vcn"
}

variable "vcn_cidr" {
  description = "VCN CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDRs for public subnets (LB only)"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs for private subnets (VMs)"
  type        = list(string)
  default     = ["10.0.11.0/24"]
}

variable "freeform_tags" {
  description = "Freeform tags applied to all VCN resources"
  type        = map(string)
  default     = {}
}
