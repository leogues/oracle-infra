module "grafana" {
  source = "../../../../modules/helm-stack"

  name      = "grafana"
  namespace = "monitoring"

  repository    = "https://grafana.github.io/helm-charts"
  chart         = "grafana"
  chart_version = "10.5.15"

  values_files = ["${path.module}/stacks/grafana/values.yaml"]

  resources_path = "${path.module}/stacks/grafana/resources"

  depends_on_resources = [
    module.longhorn,
    module.nginx_gateway,
    module.mimir,
    module.loki,
    module.prometheus_operator_crds,
  ]
}
