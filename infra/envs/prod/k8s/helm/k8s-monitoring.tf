module "k8s_monitoring" {
  source = "../../../../modules/helm-stack"

  name      = "k8s-monitoring"
  namespace = "monitoring"

  repository    = "https://grafana.github.io/helm-charts"
  chart         = "k8s-monitoring"
  chart_version = "4.1.1"

  values_files = ["${path.module}/stacks/k8s-monitoring/values.yaml"]
}
