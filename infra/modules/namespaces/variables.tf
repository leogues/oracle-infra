variable "default_namespaces" {
  description = "Baseline namespaces required by the platform stacks."
  type        = list(string)
  default = [
    "argocd",
    "cnpg-system",
    "database",
    "debug",
    "dns",
    "gateway-system",
    "longhorn-system",
    "monitoring",
    "production",
  ]
}

variable "extra_namespaces" {
  description = "Additional namespaces to create on top of the defaults."
  type        = list(string)
  default     = []
}
