output "namespaces" {
  description = "Map of created namespace names → resource metadata."
  value       = { for k, v in kubernetes_namespace.this : k => v.metadata[0].name }
}
