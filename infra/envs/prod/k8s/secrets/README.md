# k8s secrets

SOPS + age encrypted Kubernetes secrets, materialized by Terraform.

- TFC workspace: `harus-infra-prod-k8s-secrets`
- Encryption: age recipient defined in `.sops.yaml`
- One `.enc.json` file per namespace under `namespaces/<ns>/`
- Each top-level key in the JSON becomes one `Secret` in that namespace

All commands below assume cwd = this directory:

```bash
cd infra/envs/prod/k8s/secrets
```

## Bootstrap (first time only)

```bash
# install tools
brew install sops age      # or: apt install age && curl -sL https://github.com/getsops/sops/releases/...

# create the age keypair (private key never leaves this folder; never committed)
mkdir -p keys
age-keygen -o keys/age.key
grep "public key" keys/age.key
# → paste the age1... public key into .sops.yaml as the recipient
```

`keys/age.key` is `.gitignore`d. Back it up to a password manager — losing it makes every `.enc.json` unrecoverable.

## Edit secrets

```bash
# Decrypt (writes *.dec.json, removes *.enc.json)
./scripts/decrypt.sh

# Edit namespaces/<namespace>/*.dec.json

# Encrypt back (writes *.enc.json, removes *.dec.json)
./scripts/encrypt.sh
```

JSON format (per `.enc.json` file):
```json
{
  "secret-name": {
    "data": {
      "KEY": "value"
    },
    "description_unencrypted": "Secret description",
    "labels_unencrypted": {
      "app.kubernetes.io/name": "example"
    }
  }
}
```

Rules:
- Folder name = K8s namespace. `namespaces/production/app.enc.json` → secrets in namespace `production`.
- Each top-level key inside the JSON becomes one `Secret` resource with that name.
- `data` is encrypted. `*_unencrypted` siblings stay readable so the manifest layout is reviewable in the encrypted form too.
- `labels_unencrypted` is optional. Use it when a secret needs labels (e.g. Argo CD repo creds need `argocd.argoproj.io/secret-type: repository`).

## Apply

```bash
SOPS_AGE_KEY_FILE=keys/age.key terraform plan
SOPS_AGE_KEY_FILE=keys/age.key terraform apply
```

The `sops-secrets` module decrypts each file in memory and creates the `kubernetes_secret_v1` resources. Nothing decrypted is written to disk.

## What lives here

| Namespace | Secret(s) | Used by |
|---|---|---|
| `argocd` | repo creds (GitHub App for `oracle-gitops`, etc.) | Argo CD, image-updater |
| `database` | `superuser-secret`, `user-secret` | cnpg-cluster (Postgres) |
| `dns` | Cloudflare API token | cert-manager DNS-01, external-dns |
| `monitoring` | `grafana-admin`, `s3-credentials`, `mimir-s3-credentials` | Grafana, Loki, Mimir |
| `production` | per-app env secrets (`live-link-secret`, `music-hub-secret`, …) | Application deployments via `envFrom` |
