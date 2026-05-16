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
