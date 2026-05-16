terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
  }
}

locals {
  namespaces = toset(concat(var.default_namespaces, var.extra_namespaces))
}

resource "kubernetes_namespace" "this" {
  for_each = local.namespaces

  metadata {
    name = each.value
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}
