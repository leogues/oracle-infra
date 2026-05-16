variable "secrets_dir" {
  description = "Directory containing <namespace>/<file>.enc.json SOPS-encrypted secret manifests."
  type        = string
}
