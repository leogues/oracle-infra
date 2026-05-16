module "external_dns" {
  source = "../../../../modules/helm-stack"

  name      = "external-dns"
  namespace = "dns"

  repository    = "https://kubernetes-sigs.github.io/external-dns/"
  chart         = "external-dns"
  chart_version = "1.21.1"

  values_files = ["${path.module}/stacks/external-dns/values.yaml"]

  depends_on_resources = [
    module.cert_manager,
    kubectl_manifest.gateway_api_crds,
    module.nginx_gateway,
  ]
}
