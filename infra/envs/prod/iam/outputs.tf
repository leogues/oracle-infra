output "identity" {
  description = "Aggregated IAM outputs consumed by downstream layers via terraform_remote_state."
  value = {
    dynamic_group_name = module.iam_ccm.dynamic_group_name
    dynamic_group_id   = module.iam_ccm.dynamic_group_id
    policy_id          = module.iam_ccm.policy_id
  }
}
