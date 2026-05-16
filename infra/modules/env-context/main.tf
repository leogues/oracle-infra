locals {
  name_prefix = "${var.org}-${var.env}-${var.layer}"

  base_freeform = {
    org         = var.org
    env         = var.env
    layer       = var.layer
    owner       = var.owner
    cost_center = var.cost_center
    managed_by  = "terraform"
    repo        = var.repo
  }
}
