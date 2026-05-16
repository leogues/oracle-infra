#!/usr/bin/env bash
set -euo pipefail

readonly ENV="prod"
readonly KUBECONFIG_NAME="k3s-harus"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPUTE_DIR="${REPO_ROOT}/infra/envs/${ENV}/compute"
KUBECONFIG_OUT="${KUBECONFIG_OUT:-${HOME}/.kube/${KUBECONFIG_NAME}}"

IP="$(terraform -chdir="${COMPUTE_DIR}" output -raw server_private_ip)"

ssh "ubuntu@${IP}" "sudo chown -R ubuntu:ubuntu ~/.kube 2>/dev/null || mkdir -p ~/.kube; sudo install -o ubuntu -g ubuntu -m 600 /etc/rancher/k3s/k3s.yaml ~/.kube/${KUBECONFIG_NAME}"

mkdir -p "$(dirname "${KUBECONFIG_OUT}")"
scp "ubuntu@${IP}:~/.kube/${KUBECONFIG_NAME}" "${KUBECONFIG_OUT}"

sed -i "s|https://127.0.0.1:6443|https://${IP}:6443|" "${KUBECONFIG_OUT}"
chmod 600 "${KUBECONFIG_OUT}"

echo "kubeconfig -> ${KUBECONFIG_OUT}"
