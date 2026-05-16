output "release_name" {
  value = helm_release.this.name
}

output "namespace" {
  value = helm_release.this.namespace
}

output "release_status" {
  value = helm_release.this.status
}
