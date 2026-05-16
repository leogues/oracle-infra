variable "name" {
  description = "Helm release name (also used as default namespace if namespace is empty)"
  type        = string
}

variable "namespace" {
  description = "Target namespace (must already exist — managed by the namespaces workspace)"
  type        = string
}

variable "repository" {
  description = "Helm repo URL. Leave empty when chart is a local path or OCI ref."
  type        = string
  default     = ""
}

variable "chart" {
  description = "Chart name, local path, or OCI ref"
  type        = string
}

variable "chart_version" {
  description = "Chart version. Required when repository is set."
  type        = string
  default     = ""
}

variable "values_files" {
  description = "List of values.yaml file paths (later overrides earlier)"
  type        = list(string)
  default     = []
}

variable "values_inline" {
  description = "List of values.yaml content strings (later overrides earlier). Use when value comes from a resource (e.g., templatefile output) — bypasses file() plan-time check."
  type        = list(string)
  default     = []
}

variable "set" {
  description = "Inline --set overrides (non-sensitive)"
  type        = map(string)
  default     = {}
}

variable "set_sensitive" {
  description = "Inline --set overrides (sensitive)"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "wait" {
  description = "Wait for chart resources to be ready before completing"
  type        = bool
  default     = true
}

variable "atomic" {
  description = "Roll back on install failure"
  type        = bool
  default     = true
}

variable "timeout" {
  description = "Helm timeout in seconds"
  type        = number
  default     = 600
}

variable "resources_path" {
  description = "Path to a directory containing kustomization.yaml. Empty disables post-helm manifests."
  type        = string
  default     = ""
}

variable "depends_on_resources" {
  description = "Arbitrary objects to gate helm release on (e.g. CRDs from another stack)"
  type        = any
  default     = []
}
