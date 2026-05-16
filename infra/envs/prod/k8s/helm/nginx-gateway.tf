module "nginx_gateway" {
  source = "../../../../modules/helm-stack"

  name      = "nginx-gateway"
  namespace = "gateway-system"

  chart         = "oci://ghcr.io/nginx/charts/nginx-gateway-fabric"
  chart_version = "2.6.0"

  values_files   = ["${path.module}/stacks/nginx-gateway/values.yaml"]
  resources_path = "${path.module}/stacks/nginx-gateway/resources"

  depends_on_resources = [
    kubectl_manifest.gateway_api_crds,
    module.cert_manager,
  ]
}
