module "argocd_image_updater" {
  source = "../../../../modules/helm-stack"

  name      = "argocd-image-updater"
  namespace = "argocd"

  repository    = "https://argoproj.github.io/argo-helm"
  chart         = "argocd-image-updater"
  chart_version = "1.1.5"

  values_files = ["${path.module}/stacks/argocd-image-updater/values.yaml"]

  resources_path = "${path.module}/stacks/argocd-image-updater/resources"

  depends_on_resources = [
    module.argocd,
  ]
}
