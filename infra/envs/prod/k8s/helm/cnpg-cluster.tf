module "cnpg_cluster" {
  source = "../../../../modules/helm-stack"

  name      = "postgres"
  namespace = "database"

  repository    = "https://cloudnative-pg.github.io/charts"
  chart         = "cluster"
  chart_version = "0.6.0"

  values_files = ["${path.module}/stacks/cnpg-cluster/values.yaml"]

  depends_on_resources = [
    module.cnpg_operator,
    module.longhorn,
  ]
}
