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

variable "vcn_cidr" {
  description = "VCN CIDR block — prod uses 10.0.0.0/16"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs (LB only)"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs (VMs)"
  type        = list(string)
  default     = ["10.0.11.0/24"]
}
