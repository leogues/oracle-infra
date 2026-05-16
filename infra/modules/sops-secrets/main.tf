terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = ">= 0.7"
    }
  }
}

locals {
  encrypted_files = fileset(var.secrets_dir, "*/*.enc.json")

  secret_specs = merge([
    for relative_path in local.encrypted_files : {
      for secret_name, spec in jsondecode(file("${var.secrets_dir}/${relative_path}")) :
      secret_name => merge(spec, { namespace = split("/", relative_path)[0] })
      if secret_name != "sops"
    }
  ]...)

  required_namespaces = toset([for spec in local.secret_specs : spec.namespace])
}

data "sops_file" "manifest" {
  for_each    = toset(local.encrypted_files)
  source_file = "${var.secrets_dir}/${each.value}"
}

locals {
  decrypted_secrets = merge([
    for decrypted_file in data.sops_file.manifest : {
      for secret_name, payload in jsondecode(decrypted_file.raw) :
      secret_name => payload
      if secret_name != "sops"
    }
  ]...)
}

resource "kubectl_manifest" "namespace" {
  for_each = local.required_namespaces

  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "Namespace"
    metadata = {
      name = each.value
    }
  })

  server_side_apply = true
  force_conflicts   = false
  apply_only        = true
  wait_for_rollout  = false
}

resource "kubernetes_secret" "this" {
  for_each = local.secret_specs

  metadata {
    name      = each.key
    namespace = each.value.namespace
    labels    = lookup(each.value, "labels_unencrypted", null)
  }

  data = local.decrypted_secrets[each.key].data

  depends_on = [kubectl_manifest.namespace]
}
