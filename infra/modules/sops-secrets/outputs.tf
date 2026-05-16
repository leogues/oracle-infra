output "secret_names" {
  description = "Names of all kubernetes_secret resources managed by this module."
  value       = keys(kubernetes_secret.this)
}
