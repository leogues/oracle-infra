#!/usr/bin/env bash
set -euo pipefail

readonly ENV="${ENV:-prod}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_ROOT="${REPO_ROOT}/infra/envs/${ENV}"
AGE_KEY="${SOPS_AGE_KEY_FILE:-${ENV_ROOT}/k8s/secrets/keys/age.key}"
TFC_CREDS="${HOME}/.terraform.d/credentials.tfrc.json"

REQUIRED_TFVARS_LAYERS=(iam net compute)

fail=0
note() { printf '[preflight] %s\n' "$*"; }
err()  { printf '[preflight] ERROR: %s\n' "$*" >&2; fail=1; }

for layer in "${REQUIRED_TFVARS_LAYERS[@]}"; do
  tfvars="${ENV_ROOT}/${layer}/terraform.tfvars"
  if [[ ! -f "${tfvars}" ]]; then
    err "missing ${tfvars} (copy from terraform.tfvars.example and fill in secrets)"
  fi
done

if [[ ! -f "${AGE_KEY}" ]]; then
  err "missing SOPS age key at ${AGE_KEY}"
fi

if [[ ! -f "${TFC_CREDS}" ]]; then
  err "no Terraform Cloud credentials at ${TFC_CREDS} (run: terraform login)"
fi

for cmd in terraform jq ssh scp; do
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    err "required command not in PATH: ${cmd}"
  fi
done

if (( fail )); then
  echo "" >&2
  echo "Preflight failed. Fix the items above and re-run." >&2
  exit 1
fi

note "OK — tfvars, age key, TFC credentials, and required CLIs all present."
