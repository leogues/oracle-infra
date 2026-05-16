#!/usr/bin/env bash
set -euo pipefail

readonly ENV="prod"
readonly KUBECONFIG_NAME="k3s-harus"
readonly SSH_TIMEOUT="${SSH_TIMEOUT:-15}"
readonly POLL_INTERVAL="${POLL_INTERVAL:-10}"
readonly MAX_WAIT_SECONDS="${MAX_WAIT_SECONDS:-600}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPUTE_DIR="${REPO_ROOT}/infra/envs/${ENV}/compute"
KUBECONFIG_OUT="${KUBECONFIG_OUT:-${HOME}/.kube/${KUBECONFIG_NAME}}"

SSH_OPTS=(
  -o BatchMode=yes
  -o StrictHostKeyChecking=accept-new
  -o ConnectTimeout="${SSH_TIMEOUT}"
  -o ServerAliveInterval=10
)

log() { printf '[kubeconfig] %s\n' "$*"; }
die() { echo "ERROR: $*" >&2; exit 1; }

resolve_server_ip() {
  local ip
  ip="$(terraform -chdir="${COMPUTE_DIR}" output -json compute | jq -r '.server.private_ip')"
  [[ -n "${ip}" && "${ip}" != "null" ]] || die "could not read compute.server.private_ip; did 'make compute' succeed?"
  printf '%s' "${ip}"
}

wait_for_ssh() {
  local ip="$1" deadline="$2"
  log "waiting for SSH on ${ip} (max ${MAX_WAIT_SECONDS}s)..."
  while ! ssh "${SSH_OPTS[@]}" "ubuntu@${ip}" 'true' 2>/dev/null; do
    (( $(date +%s) > deadline )) && die "SSH never came up. Is WARP connected? Is the VM running?"
    sleep "${POLL_INTERVAL}"
  done
  log "SSH OK."
}

wait_for_k3s_ready() {
  local ip="$1" deadline="$2"
  log "waiting for k3s server to be Ready..."
  while ! ssh "${SSH_OPTS[@]}" "ubuntu@${ip}" \
      "sudo test -r /etc/rancher/k3s/k3s.yaml && sudo /usr/local/bin/kubectl --kubeconfig=/etc/rancher/k3s/k3s.yaml get nodes 2>/dev/null | awk 'NR>1 && \$1 ~ /server/ {print \$2}' | grep -qx Ready"; do
    (( $(date +%s) > deadline )) && die "k3s never became Ready on ${ip} within ${MAX_WAIT_SECONDS}s."
    sleep "${POLL_INTERVAL}"
  done
  log "k3s Ready."
}

fetch_kubeconfig() {
  local ip="$1"
  ssh "${SSH_OPTS[@]}" "ubuntu@${ip}" \
    "mkdir -p ~/.kube && sudo install -o ubuntu -g ubuntu -m 600 /etc/rancher/k3s/k3s.yaml ~/.kube/${KUBECONFIG_NAME}"

  mkdir -p "$(dirname "${KUBECONFIG_OUT}")"
  scp "${SSH_OPTS[@]}" "ubuntu@${ip}:~/.kube/${KUBECONFIG_NAME}" "${KUBECONFIG_OUT}"

  sed -i "s|https://127.0.0.1:6443|https://${ip}:6443|" "${KUBECONFIG_OUT}"
  chmod 600 "${KUBECONFIG_OUT}"
  log "kubeconfig -> ${KUBECONFIG_OUT}"
}

copy_to_windows_host() {
  grep -qiE 'microsoft|wsl' /proc/sys/kernel/osrelease 2>/dev/null || return 0
  command -v cmd.exe >/dev/null 2>&1 || return 0

  local win_user win_home win_kube_dir win_kube_out
  win_user="$(cmd.exe /C 'echo %USERNAME%' 2>/dev/null | tr -d '\r\n ')"
  [[ -n "${win_user}" ]] || return 0

  win_home="/mnt/c/Users/${win_user}"
  if [[ ! -d "${win_home}" ]]; then
    log "WSL detected but ${win_home} not found; skipping Windows copy."
    return 0
  fi

  win_kube_dir="${win_home}/.kube"
  win_kube_out="${win_kube_dir}/${KUBECONFIG_NAME}"
  mkdir -p "${win_kube_dir}"
  cp "${KUBECONFIG_OUT}" "${win_kube_out}"
  log "kubeconfig -> ${win_kube_out} (Windows host: ${win_user})"
}

IP="$(resolve_server_ip)"
log "k3s server: ${IP}"

DEADLINE=$(( $(date +%s) + MAX_WAIT_SECONDS ))
wait_for_ssh "${IP}" "${DEADLINE}"
wait_for_k3s_ready "${IP}" "${DEADLINE}"
fetch_kubeconfig "${IP}"
copy_to_windows_host
