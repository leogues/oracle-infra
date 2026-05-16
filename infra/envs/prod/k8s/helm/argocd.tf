module "argocd" {
  source = "../../../../modules/helm-stack"

  name      = "argocd"
  namespace = "argocd"

  repository    = "https://argoproj.github.io/argo-helm"
  chart         = "argo-cd"
  chart_version = "9.5.13"

  values_files = ["${path.module}/stacks/argocd/values.yaml"]

  resources_path = "${path.module}/stacks/argocd/resources"

  depends_on_resources = [
    module.cert_manager,
    module.nginx_gateway,
  ]
}
