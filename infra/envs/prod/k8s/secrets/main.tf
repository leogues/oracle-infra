module "secrets" {
  source = "../../../../modules/sops-secrets"

  secrets_dir = "${path.module}/namespaces"
}
