# oracle-infra

Oracle Cloud Infrastructure (OCI) Always Free homelab for the **Harus**
project. K3s on ARM A1.Flex split across **1 server + N workers**. Ingress
goes through an OCI Flexible Network Load Balancer provisioned by the **OCI
Cloud Controller Manager (CCM)** from a `Service type=LoadBalancer`. State
lives in Terraform Cloud (org `Harus`), execution mode is local — plan/apply
run on your machine, state stays remote.

This repo owns **only** the cloud infrastructure plus the Argo CD bootstrap.
The rest of the cluster (Longhorn, cert-manager, gateway-api, monitoring,
postgres, etc.) lives in [`leogues/oracle-gitops`](https://github.com/leogues/oracle-gitops)
and is reconciled by Argo CD running inside the cluster.

## Layout

```
infra/
├── modules/
│   ├── env-context/        # Pure-locals — derives name_prefix + freeform_tags from (org, env, layer)
│   ├── vcn/                # VCN, IGW, NAT GW, Service GW, subnets, route tables, security lists
│   ├── compute-common/     # A1.Flex VM + NSG + image lookup (user_data injected by wrappers)
│   ├── compute-server/     # k3s server cloud-init (CCM + cloudflared + helm) → wraps compute-common
│   ├── compute-worker/     # k3s agent cloud-init → wraps compute-common
│   ├── iam-ccm/            # IAM dynamic group + policy for OCI CCM instance principal
│   ├── helm-stack/         # Generic Helm release + kustomization wrapper (used by Argo CD bootstrap)
│   └── sops-secrets/       # SOPS+age → kubernetes_secret_v1 + idempotent namespace ensure (SSA)
└── envs/
    ├── _common/            # Convention docs (naming, tagging, workspace policy)
    └── prod/
        ├── iam/            # workspace: harus-prod-iam
        ├── net/            # workspace: harus-prod-net
        ├── compute/        # workspace: harus-prod-compute
        └── k8s/
            ├── secrets/    # workspace: harus-prod-k8s-secrets   (SOPS-encrypted manifests + namespace SSA)
            └── helm/       # workspace: harus-prod-k8s-helm      (Argo CD bootstrap + platform root Application)
```

Naming convention and tag taxonomy are documented in
[`infra/envs/_common/README.md`](infra/envs/_common/README.md).

## Bootstrap responsibility split

| Layer | Owns                                                     |
| ----- | -------------------------------------------------------- |
| `iam` | Dynamic group + IAM policy for OCI CCM instance principal |
| `net` | VCN, IGW, NAT/Service GW, public + private subnets, route tables, security lists |
| `compute` | k3s server + worker VMs. Cloud-init installs k3s, CCM, and cloudflared (Cloudflare Zero Trust tunnel) |
| `k8s/secrets` | SOPS-encrypted secrets decrypted in-memory and applied as `kubernetes_secret_v1`. Ensures every target namespace exists via `kubectl_manifest` server-side apply with `apply_only=true` (does not destroy on `terraform destroy`) |
| `k8s/helm` | Argo CD chart (Helm) + a single **cluster-root** Application that points at `oracle-gitops/cluster/`. From there Argo CD reconciles its own config (AppProjects, the environments ApplicationSet, and the platform-root Application) and takes over. |

Everything beyond Argo CD itself — Longhorn, cert-manager, external-dns,
nginx-gateway, cnpg, k8s-monitoring, mimir, loki, grafana,
argocd-image-updater, gateway-api CRDs, prometheus-operator-crds — is
managed by Argo CD from the gitops repo.

## Free tier footprint

All resources are Always Free:

| Resource                                              | Count  | Free tier limit                       |
| ----------------------------------------------------- | ------ | ------------------------------------- |
| VCN                                                   | 1      | 2                                     |
| IGW / NAT GW / Service GW                             | 1 each | unlimited                             |
| Public + private subnets                              | 1 + 1  | unlimited                             |
| VM A1.Flex 2 OCPU / 12 GB / 100 GB (server + workers) | 1 + N  | 4 OCPU / 24 GB / 200 GB block storage |
| Flexible Network Load Balancer (CCM-managed)          | 1      | 1                                     |
| Egress                                                | —      | 10 TB/month                           |

Default sizing fits 1 server + 1 worker. Bump `worker_size` only if free-tier
room allows.

Object storage for Mimir / Loki is **Cloudflare R2** (10 GB free), not OCI.

## Network shape

- VCN `harus-prod-net-vcn-01` `10.0.0.0/16` in `sa-vinhedo-1` (single AD)
- Public subnet `10.0.1.0/24` — the CCM-managed NLB lives here
- Private subnet `10.0.11.0/24` — VMs live here (server + all workers; workers spread across fault domains, not subnets)
- VMs have **no public IP**. Access is via the Cloudflare Zero Trust tunnel deployed in-cluster by the server cloud-init.
- The CCM-provisioned NLB exposes `:80` and `:443` as L4 TCP passthrough. Source IP is preserved natively (`is-preserve-source: true` + `externalTrafficPolicy: Local`); no PROXY protocol needed.
- `kube-apiserver :6443` is **not** exposed by the LB — reach it through the tunnel.

## Apply order

The whole platform comes up with **one command**:

```bash
make all
```

This runs `doctor` (preflight check) → `iam` → `net` → `compute` →
`kubeconfig` (polls SSH + k3s readiness on the server VM, up to 10 minutes
by default) → `secrets` → `helm`. Each layer also has its own target if you
need to re-run something individually.

`make doctor` runs the preflight on its own — verifies that
`terraform.tfvars` exists for the layers that need OCI credentials, that
the SOPS age key is present, that `~/.terraform.d/credentials.tfrc.json`
exists from `terraform login`, and that the required CLIs
(`terraform`, `jq`, `ssh`, `scp`) are in `PATH`.

To tear everything down: `make destroy-all` (reverse order). Individual
`-destroy` targets exist for each layer. Format all `.tf` with `make fmt`.

`SOPS_AGE_KEY_FILE` defaults to `infra/envs/prod/k8s/secrets/keys/age.key`.
Override per-invocation:
`make secrets SOPS_AGE_KEY_FILE=/path/to/age.key`.

### Cluster-resource cleanup before destroy

Before running `make destroy-all`, delete the LoadBalancer Service so the
CCM cleans up the OCI NLB. Otherwise the NLB is orphaned in OCI and stays
on your free-tier quota.

```bash
# 1. Pause Argo so it does not recreate the leaf
kubectl -n argocd patch app platform-networking --type=merge \
  -p '{"spec":{"syncPolicy":{"automated":null}}}'

# 2. Delete the nginx-gateway leaf — cascade deletes the LoadBalancer Service
kubectl -n argocd delete app nginx-gateway --cascade=foreground

# 3. Wait for the NLB to disappear in the OCI Console

# 4. make destroy-all
```

## Cross-workspace reads

`compute` reads the `net` workspace via `data "terraform_remote_state"`
against the `remote` backend. `iam` and `net` have no cross-layer reads —
they can run in either order, but the Makefile applies them in
`iam → net → compute` order out of habit.

## Terraform Cloud setup

Workspaces in org `Harus`, all with **Execution Mode = Local**:

- `harus-prod-iam`
- `harus-prod-net`
- `harus-prod-compute`
- `harus-prod-k8s-secrets`
- `harus-prod-k8s-helm`

Authenticate once with `terraform login` (writes
`~/.terraform.d/credentials.tfrc.json`). That token authenticates the
`remote` backend for both state operations and cross-workspace state reads.

## Variables (`terraform.tfvars`)

Each layer has its own `terraform.tfvars.example`. Copy it locally (real
`.tfvars` are git-ignored):

```bash
cp infra/envs/prod/<layer>/terraform.tfvars.example infra/envs/prod/<layer>/terraform.tfvars
$EDITOR infra/envs/prod/<layer>/terraform.tfvars
```

| Var                       | Description                               | Layers              |
| ------------------------- | ----------------------------------------- | ------------------- |
| `tenancy_ocid`            | OCI tenancy OCID                          | iam, net, compute   |
| `user_ocid`               | OCI user OCID                             | iam, net, compute   |
| `fingerprint`             | API key fingerprint                       | iam, net, compute   |
| `private_key`             | API private key (PEM contents, heredoc)   | iam, net, compute   |
| `region`                  | `sa-vinhedo-1`                            | iam, net, compute   |
| `compartment_ocid`        | target compartment OCID                   | iam, net, compute   |
| `ssh_public_key`          | SSH pubkey for the `ubuntu` user          | compute             |
| `cloudflare_tunnel_token` | Zero Trust tunnel token from CF dashboard | compute             |
| `worker_size`             | Number of k3s worker VMs (default 1)      | compute             |
| `vcn_cidr`                | VCN CIDR (default `10.0.0.0/16`)          | net                 |
| `public_subnet_cidrs`     | Public subnet CIDRs                       | net                 |
| `private_subnet_cidrs`    | Private subnet CIDRs                      | net                 |
| `kubeconfig_path`         | path to kubeconfig file                   | k8s/\*              |
| `kubeconfig_context`      | context name inside the kubeconfig        | k8s/\*              |

## Outputs

Each layer emits a single aggregated object (read downstream via
`data "terraform_remote_state"`):

- `iam.identity` — `dynamic_group_name`, `dynamic_group_id`, `policy_id`
- `net.network` — `compartment_ocid`, `vcn_id`, `vcn_cidr`, `subnets.{public,private}` (maps keyed by `p1`, one entry per tier), `availability_domains`, `gateways.{internet,nat,service}`
- `compute.compute` — `server.{instance_id,private_ip,nsg_id,server_url}`, `workers["k3s-worker-NN"].{instance_id,private_ip,nsg_id}`, plus `k3s_token` as a separate sensitive output

The NLB IP is not a Terraform output — it lives on the nginx-gateway
`Service.status.loadBalancer.ingress` once CCM provisions it, and external-dns
reads Gateway status to publish DNS records.

## Pre-commit hooks

The repo ships a `.pre-commit-config.yaml` that runs `terraform fmt`,
`terraform validate`, whitespace cleanup, JSON/YAML lint, merge-conflict
and private-key detection, plus `shellcheck` on `scripts/`. SOPS
`*.enc.json` files are excluded from every whitespace/format hook because
any byte mutation breaks the SOPS MAC.

```bash
pip install pre-commit          # or pipx install pre-commit
pre-commit install              # installs the .git/hooks/pre-commit hook
pre-commit run --all-files      # one-off check
```

`tflint` and `trivy` hooks are intentionally left out — they need extra
binaries. Add them when those binaries are installed.

## Post-deploy

1. Cloudflare dashboard → Zero Trust → Networks → Tunnels → enable
   **private network routing** for the VCN CIDR (`10.0.0.0/16`). The
   cloudflared pod (on the server node) is the in-cluster gateway into
   that network.
2. Connect with the **Cloudflare WARP** client (Zero Trust enrollment).
   Once connected, the server's private IP is reachable directly — no
   public hostname needed.
3. `make kubeconfig` fetches kubeconfig from the server VM over WARP and
   writes it to `~/.kube/k3s-harus`.
4. After `make secrets && make helm`, Argo CD bootstraps from
   `oracle-gitops/platform/`. CCM untaints the nodes once it starts;
   nginx-gateway then creates its `Service LoadBalancer` and CCM
   provisions the OCI NLB.
5. Argo CD also reconciles the application workloads in
   [`leogues/oracle-gitops`](https://github.com/leogues/oracle-gitops)
   under `envs/production/`. Image-updater watches Docker Hub and writes
   tag bumps back to that repo.
