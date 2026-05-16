module "longhorn" {
  source = "../../../../modules/helm-stack"

  name      = "longhorn"
  namespace = "longhorn-system"

  repository    = "https://charts.longhorn.io"
  chart         = "longhorn"
  chart_version = "1.11.2"

  values_files = ["${path.module}/stacks/longhorn/values.yaml"]
}
