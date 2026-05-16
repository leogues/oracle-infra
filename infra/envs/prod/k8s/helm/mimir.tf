module "mimir" {
  source = "../../../../modules/helm-stack"

  name      = "mimir"
  namespace = "monitoring"

  repository    = "https://grafana.github.io/helm-charts"
  chart         = "mimir-distributed"
  chart_version = "6.0.6"

  values_files = ["${path.module}/stacks/mimir/values.yaml"]

  depends_on_resources = [
    module.longhorn,
    module.k8s_monitoring,
    module.prometheus_operator_crds,
  ]
}
