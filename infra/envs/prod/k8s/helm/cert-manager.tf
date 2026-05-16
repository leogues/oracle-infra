module "cert_manager" {
  source = "../../../../modules/helm-stack"

  name      = "cert-manager"
  namespace = "dns"

  repository    = "https://charts.jetstack.io"
  chart         = "cert-manager"
  chart_version = "v1.20.2"

  values_files = ["${path.module}/stacks/cert-manager/values.yaml"]

  resources_path = "${path.module}/stacks/cert-manager/resources"
}
