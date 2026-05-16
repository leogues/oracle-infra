# oracle-infra

Oracle Cloud Infrastructure (OCI) Always Free homelab for the **Harus** project. K3s on ARM A1.Flex split across **1 server + N workers**. Ingress goes through an OCI Flexible Network Load Balancer (NLB) provisioned by the **OCI Cloud Controller Manager (CCM)** straight from a `Service type=LoadBalancer`. State in Terraform Cloud (org `Harus`), execution mode is local.

Workloads themselves live in the GitOps repo [`leogues/oracle-gitops`](https://github.com/leogues/oracle-gitops) and are reconciled by Argo CD running in this cluster.

## Layout

```
infra/
├── modules/
│   ├── vcn/                # VCN, IGW, NAT GW, Service GW, 4 subnets, route tables, security lists
│   ├── compute-common/     # A1.Flex VM + NSG + image lookup (user_data injected by wrappers)
│   ├── compute-server/     # k3s server cloud-init (helm + cloudflared) → wraps compute-common
│   ├── compute-worker/     # k3s agent cloud-init → wraps compute-common
│   ├── iam-ccm/            # IAM dynamic group + policy for OCI CCM instance principal
│   ├── namespaces/         # K8s namespace bootstrap
│   ├── helm-stack/         # Generic Helm release + kustomization wrapper (used by every chart)
│   └── sops-secrets/       # SOPS+age → kubernetes_secret_v1 with per-file/per-namespace layout
└── envs/prod/
    ├── vcn/                # workspace: harus-infra-prod-network
    ├── iam/                # workspace: harus-infra-prod-iam
    ├── compute/            # workspace: harus-infra-prod-compute
    └── k8s/
        ├── namespaces/     # workspace: harus-infra-prod-k8s-namespaces
        ├── secrets/        # workspace: harus-infra-prod-k8s-secrets (SOPS-encrypted manifests)
        └── helm/           # workspace: harus-infra-prod-k8s-helm   (the full platform stack)
```

## Platform stack (`envs/prod/k8s/helm/`)

All charts are deployed via the `helm-stack` module. Dependency order is encoded in `depends_on_resources`. A clean `terraform apply` brings up the whole platform.

| Stack                      | Chart / Source           | Purpose                                                                 |
| -------------------------- | ------------------------ | ----------------------------------------------------------------------- |
| `oci-ccm`                  | manifests (Oracle 1.34)  | Cloud Controller Manager — provisions OCI Load Balancers from Services  |
| `longhorn`                 | longhorn 1.11            | Block storage (default StorageClass)                                    |
| `gateway-api`              | (CRDs)                   | Gateway API v1.5.1 manifests                                            |
| `nginx-gateway`            | nginx-gateway-fabric 2.6 | GatewayClass implementation (Service `LoadBalancer` → CCM creates NLB)  |
| `cert-manager`             | cert-manager v1.20       | TLS via Let's Encrypt + Cloudflare DNS-01                               |
| `external-dns`             | external-dns 1.21        | Sync Gateway HTTPRoute hostnames → Cloudflare DNS                       |
| `cnpg-operator`            | cloudnative-pg 0.28      | Postgres operator                                                       |
| `cnpg-cluster`             | cluster 0.6              | Postgres cluster instance                                               |
| `prometheus-operator-crds` | 29.0                     | ServiceMonitor / PodMonitor CRDs (shared)                               |
| `k8s-monitoring`           | k8s-monitoring 4.1       | Grafana Alloy collectors (logs/metrics/singleton) + KSM + node-exporter |
| `mimir`                    | mimir-distributed 6.0    | Metrics backend (S3/R2 storage)                                         |
| `loki`                     | loki 7.0                 | Logs backend (S3/R2 storage)                                            |
| `grafana`                  | grafana 10.5             | UI for metrics/logs/dashboards                                          |
| `argocd`                   | argo-cd 9.5              | GitOps controller for app workloads                                     |
| `argocd-image-updater`     | argocd-image-updater 1.1 | Auto-bump Docker tags in the gitops repo                                |

## Free tier footprint

All resources are Always Free:

| Resource                                              | Count     | Free tier limit |
| ----------------------------------------------------- | --------- | --------------- |
| VCN                                                   | 1         | 2               |
| IGW / NAT GW / Service GW                             | 1 each    | unlimited       |
| Subnets (2 public + 2 private)                        | 4         | unlimited       |
| VM A1.Flex 2 OCPU / 12 GB / 100 GB (server + workers) | 1 + N     | 4 OCPU / 24 GB / 200 GB block storage |
| Flexible Network Load Balancer (CCM-managed)          | 1         | 1               |
| Egress                                                | —         | 10 TB/month     |

Default sizing fits 1 server + 1 worker. Bump `worker_size` only if free-tier room allows.

Object storage for Mimir/Loki is **Cloudflare R2** (10 GB free), not OCI.

## Network shape

- VCN `harus-prod` `10.0.0.0/16` in `sa-vinhedo-1` (single AD)
- Public subnets `10.0.1.0/24`, `10.0.2.0/24` — CCM-managed NLB lives here
- Private subnets `10.0.11.0/24`, `10.0.12.0/24` — VMs live here (workers round-robin across both)
- VMs have **no public IP**. Access via Cloudflare Zero Trust tunnel (deployed in-cluster by server cloud-init)
- CCM-provisioned NLB exposes `:80` and `:443` as L4 TCP passthrough. Source IP preserved natively (`is-preserve-source: true` + `externalTrafficPolicy: Local`), no PROXY protocol needed
- kube-apiserver `:6443` is **not** exposed by the LB — reach it through the tunnel

## Apply order

```bash
cd infra/envs/prod/vcn       && terraform init && terraform apply
cd ../iam                     && terraform init && terraform apply
cd ../compute                 && terraform init && terraform apply
# wait for k3s bootstrap (~3 min) and pull the kubeconfig — see Post-deploy below
cd ../k8s/namespaces          && terraform init && terraform apply
cd ../secrets                 && terraform init && SOPS_AGE_KEY_FILE=keys/age.key terraform apply
cd ../helm                    && terraform init && terraform apply
```

`compute` depends on `vcn` outputs. The k8s/helm layer reads `compartment_ocid`, `vcn_id`, and `public_subnet_ids` from the network workspace to configure CCM.

## Terraform Cloud setup

Workspaces in org `Harus`, all with **Execution Mode = Local** (state goes to TF Cloud, plan/apply run on your machine):

- `harus-infra-prod-network`
- `harus-infra-prod-iam`
- `harus-infra-prod-compute`
- `harus-infra-prod-k8s-namespaces`
- `harus-infra-prod-k8s-helm`
- `harus-infra-prod-k8s-secrets`

Authenticate once with `terraform login` (writes `~/.terraform.d/credentials.tfrc.json`). The TFE provider needs that token to read cross-workspace outputs.

## Variables (`terraform.tfvars`)

Each layer has its own `terraform.tfvars.example`. Copy it locally (file is gitignored):

```bash
cp infra/envs/prod/<layer>/terraform.tfvars.example infra/envs/prod/<layer>/terraform.tfvars
$EDITOR infra/envs/prod/<layer>/terraform.tfvars
```

| Var                       | Description                               | Layers              |
| ------------------------- | ----------------------------------------- | ------------------- |
| `tenancy_ocid`            | OCI tenancy OCID                          | vcn, iam, compute   |
| `user_ocid`               | OCI user OCID                             | vcn, iam, compute   |
| `fingerprint`             | API key fingerprint                       | vcn, iam, compute   |
| `private_key`             | API private key (PEM contents, heredoc)   | vcn, iam, compute   |
| `region`                  | `sa-vinhedo-1`                            | vcn, iam, compute   |
| `compartment_ocid`        | target compartment OCID                   | vcn, iam, compute   |
| `ssh_public_key`          | SSH pubkey for the `ubuntu` user          | compute             |
| `cloudflare_tunnel_token` | Zero Trust tunnel token from CF dashboard | compute             |
| `worker_size`             | Number of k3s worker VMs (default 1)      | compute             |
| `kubeconfig_path`         | path to kubeconfig file                   | k8s/\*              |
| `kubeconfig_context`      | context name inside the kubeconfig        | k8s/\*              |

## Outputs

- network: `compartment_ocid`, `vcn_id`, `public_subnet_ids`, `private_subnet_ids`, `availability_domains`
- iam: `dynamic_group_name`, `dynamic_group_id`, `policy_id`
- compute: `server_instance_id`, `server_private_ip`, `server_nsg_id`, `worker_instance_ids`, `worker_private_ips`, `worker_nsg_ids`, `k3s_token` (sensitive)

The Load Balancer is no longer a Terraform output — its public IP lives on the nginx-gateway `Service.status.loadBalancer.ingress`. external-dns reads Gateway status to publish DNS records.

## Post-deploy

1. Cloudflare dashboard → Zero Trust → Networks → Tunnels → enable **private network routing** for the VCN CIDR (`10.0.0.0/16`). The cloudflared pod (server node) is the in-cluster gateway into that network.
2. Connect with the **Cloudflare WARP** client (Zero Trust enrollment). Once connected, the server's private IP is reachable directly — no public hostname needed.
3. Pull the kubeconfig over WARP:
   ```bash
   ./scripts/get-kubeconfig.sh
   export KUBECONFIG=~/.kube/k3s-harus
   ```
4. Bootstrap secrets (see `infra/envs/prod/k8s/secrets/README.md`), then apply the helm layer. CCM untaints the nodes once it starts; nginx-gateway then creates its Service `LoadBalancer` and CCM provisions the OCI NLB.
5. Argo CD reconciles app workloads from [`leogues/oracle-gitops`](https://github.com/leogues/oracle-gitops). Image-updater watches Docker Hub and writes tag bumps back to that repo.
