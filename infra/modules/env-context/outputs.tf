output "org" {
  value = var.org
}

output "env" {
  value = var.env
}

output "layer" {
  value = var.layer
}

output "name_prefix" {
  description = "{org}-{env}-{layer} — prepend to every resource display_name"
  value       = local.name_prefix
}

output "freeform_tags" {
  description = "Base freeform tag map. Merge with {role = ...} per resource group."
  value       = local.base_freeform
}
