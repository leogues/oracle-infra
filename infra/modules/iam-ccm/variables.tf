variable "tenancy_ocid" {
  description = "Tenancy OCID (dynamic group and policy live at tenancy root)"
  type        = string
}

variable "compartment_ocid" {
  description = "Compartment OCID where k3s instances and load balancers live"
  type        = string
}

variable "dynamic_group_name" {
  description = "Name of the dynamic group matching k3s nodes"
  type        = string
  default     = "harus-prod-k3s-nodes"
}

variable "policy_name" {
  description = "Name of the IAM policy granting CCM permissions"
  type        = string
  default     = "harus-prod-ccm"
}

variable "tags" {
  description = "Freeform tags"
  type        = map(string)
  default     = {}
}
