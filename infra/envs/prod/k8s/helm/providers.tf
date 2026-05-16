provider "helm" {
  kubernetes = {
    config_path    = var.kubeconfig_path
    config_context = var.kubeconfig_context
  }
}

provider "kustomization" {
  kubeconfig_path = var.kubeconfig_path
  context         = var.kubeconfig_context
}
