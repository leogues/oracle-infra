module "argocd" {
  source = "../../../../modules/helm-stack"

  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true

  repository    = "https://argoproj.github.io/argo-helm"
  chart         = "argo-cd"
  chart_version = "9.5.13"

  values_files = ["${path.module}/stacks/argocd/values.yaml"]

  resources_path = "${path.module}/stacks/argocd/resources"
}
