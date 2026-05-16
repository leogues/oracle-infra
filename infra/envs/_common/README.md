# envs/_common — shared conventions

This directory documents conventions shared across every `envs/<env>/` layout.
It does **not** contain a Terraform root. The shared logic lives in
[`modules/env-context`](../../modules/env-context) — a pure-locals module that
derives `name_prefix` and `freeform_tags` from `(org, env, layer)`. Every env
layer instantiates it at the top.

## Naming convention

```
{org}-{env}-{layer}-{role}[-{nn}]
```

| Field   | Values                                          |
| ------- | ----------------------------------------------- |
| `org`   | `harus`                                         |
| `env`   | `prod` (future: `staging`, `sandbox`)           |
| `layer` | `iam`, `net`, `compute`                         |
| `role`  | resource role (`vcn`, `vm-k3s-server`, `ccm`, …) |
| `nn`    | 2-digit index, only when more than one          |

Examples:

```
harus-prod-net-vcn-01
harus-prod-net-igw-01
harus-prod-net-snet-public-01
harus-prod-net-snet-private-01
harus-prod-compute-vm-k3s-server-01
harus-prod-compute-vm-k3s-worker-01
harus-prod-compute-nsg-k3s-server-01
harus-prod-iam-dg-k3s-nodes
harus-prod-iam-pol-ccm
```

OCI **dns_label** has a 15-char alphanumeric ceiling (VCN, subnet). Modules
generate dns_label independently from display_name — see `modules/vcn`.

## Tag taxonomy

Every resource carries freeform tags emitted by `modules/env-context`:

| Tag           | Source              |
| ------------- | ------------------- |
| `org`         | `var.org`           |
| `env`         | `var.env`           |
| `layer`       | `var.layer`         |
| `role`        | set per resource    |
| `owner`       | `var.owner`         |
| `cost_center` | `var.cost_center`   |
| `managed_by`  | always `terraform`  |
| `repo`        | `var.repo`          |

Freeform-only tagging is intentional for this homelab: OCI defined-tag
namespaces add propagation delay and lifecycle complexity that does not pay
off without a FinOps policy engine consuming the tags.

## Workspace naming

Terraform Cloud workspaces follow `harus-{env}-{layer}`:

- `harus-prod-iam`
- `harus-prod-net`
- `harus-prod-compute`
- `harus-prod-k8s-secrets`
- `harus-prod-k8s-helm`

## Layer bootstrap order

```
iam → net → compute → secrets → helm
```

`iam` and `net` are independent (no cross-layer reads). `compute` reads the
`net` workspace via `data "terraform_remote_state"`. `k8s/secrets` and
`k8s/helm` need the cluster reachable (via WARP after `compute` finishes).

## Adding a new env

1. Copy `envs/prod/` to `envs/<env>/`.
2. Edit `cloud { workspaces { name } }` in every layer's `versions.tf`.
3. Edit the `env = "<env>"` argument to `module "ctx"` in every layer.
4. Allocate a fresh CIDR (`10.{0,1,10}.0.0/16` for prod/staging/sandbox).
5. Create the workspaces in Terraform Cloud (org `Harus`).
