module "cnpg_operator" {
  source = "../../../../modules/helm-stack"

  name      = "cnpg"
  namespace = "cnpg-system"

  repository    = "https://cloudnative-pg.github.io/charts"
  chart         = "cloudnative-pg"
  chart_version = "0.28.1"

  values_files = ["${path.module}/stacks/cnpg-operator/values.yaml"]

  depends_on_resources = [
    module.k8s_monitoring,
    module.prometheus_operator_crds,
  ]
}
