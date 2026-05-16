module "prometheus_operator_crds" {
  source = "../../../../modules/helm-stack"

  name      = "prometheus-operator-crds"
  namespace = "monitoring"

  repository    = "https://prometheus-community.github.io/helm-charts"
  chart         = "prometheus-operator-crds"
  chart_version = "29.0.0"
}
