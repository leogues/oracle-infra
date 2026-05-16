variable "org" {
  description = "Organisation slug (lowercased)"
  type        = string
}

variable "env" {
  description = "Environment slug — prod | staging | sandbox"
  type        = string

  validation {
    condition     = contains(["prod", "staging", "sandbox"], var.env)
    error_message = "env must be one of: prod, staging, sandbox"
  }
}

variable "layer" {
  description = "Stack layer — iam | net | compute | k8s"
  type        = string

  validation {
    condition     = contains(["iam", "net", "compute", "k8s"], var.layer)
    error_message = "layer must be one of: iam, net, compute, k8s"
  }
}

variable "owner" {
  description = "Resource owner (email or team identifier)"
  type        = string
  default     = "leonardo.rodrigues@nemu.com.br"
}

variable "cost_center" {
  description = "Billing bucket — used by FinOps queries"
  type        = string
  default     = "homelab"
}

variable "repo" {
  description = "Source repository slug"
  type        = string
  default     = "leogues/oracle-infra"
}
