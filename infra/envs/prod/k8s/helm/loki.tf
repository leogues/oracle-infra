module "loki" {
  source = "../../../../modules/helm-stack"

  name      = "loki"
  namespace = "monitoring"

  repository    = "https://grafana.github.io/helm-charts"
  chart         = "loki"
  chart_version = "7.0.0"

  values_files = ["${path.module}/stacks/loki/values.yaml"]

  depends_on_resources = [
    module.longhorn,
    module.k8s_monitoring,
    module.prometheus_operator_crds,
  ]
}
