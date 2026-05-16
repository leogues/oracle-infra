terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.0"
    }
    kustomization = {
      source  = "kbst/kustomization"
      version = ">= 0.9"
    }
  }
}

resource "helm_release" "this" {
  name             = var.name
  namespace        = var.namespace
  create_namespace = false

  repository = var.repository != "" ? var.repository : null
  chart      = var.chart
  version    = var.chart_version != "" ? var.chart_version : null

  values = concat([for f in var.values_files : file(f)], var.values_inline)

  set = [
    for k, v in var.set : {
      name  = k
      value = v
    }
  ]

  set_sensitive = [
    for k, v in var.set_sensitive : {
      name  = k
      value = v
    }
  ]

  wait    = var.wait
  atomic  = var.atomic
  timeout = var.timeout

  lifecycle {
    ignore_changes = []
  }

  depends_on = [var.depends_on_resources]
}

locals {
  resources_enabled = var.resources_path != ""
}

data "kustomization_build" "resources" {
  count = local.resources_enabled ? 1 : 0
  path  = var.resources_path
}

resource "kustomization_resource" "resources" {
  for_each = local.resources_enabled ? data.kustomization_build.resources[0].ids : toset([])

  manifest = data.kustomization_build.resources[0].manifests[each.value]

  depends_on = [helm_release.this]
}
