variable "tenancy_ocid" {
  description = "Tenancy OCID (dynamic group and policy live at tenancy root)"
  type        = string
}

variable "compartment_ocid" {
  description = "Compartment OCID where k3s instances and load balancers live"
  type        = string
}

variable "name_prefix" {
  description = "Resource name prefix — typically '{org}-{env}-{layer}' from modules/env-context"
  type        = string
}

variable "freeform_tags" {
  description = "Freeform tags applied to dynamic group and policy"
  type        = map(string)
  default     = {}
}
