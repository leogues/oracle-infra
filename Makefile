ROOT ?= infra/envs/prod
export SOPS_AGE_KEY_FILE ?= $(abspath $(ROOT)/k8s/secrets/keys/age.key)

TF_APPLY_FLAGS ?= -auto-approve

.PHONY: all doctor \
        iam iam-destroy \
        net net-destroy \
        compute compute-destroy \
        secrets secrets-destroy secrets-decrypt secrets-encrypt \
        helm helm-destroy \
        fmt kubeconfig destroy-all

doctor:
	./scripts/preflight.sh

iam:
	terraform -chdir=$(ROOT)/iam init
	terraform -chdir=$(ROOT)/iam apply $(TF_APPLY_FLAGS)

iam-destroy:
	terraform -chdir=$(ROOT)/iam destroy

net:
	terraform -chdir=$(ROOT)/net init
	terraform -chdir=$(ROOT)/net apply $(TF_APPLY_FLAGS)

net-destroy:
	terraform -chdir=$(ROOT)/net destroy

compute:
	terraform -chdir=$(ROOT)/compute init
	terraform -chdir=$(ROOT)/compute apply $(TF_APPLY_FLAGS)

compute-destroy:
	terraform -chdir=$(ROOT)/compute destroy

secrets:
	terraform -chdir=$(ROOT)/k8s/secrets init
	terraform -chdir=$(ROOT)/k8s/secrets apply $(TF_APPLY_FLAGS)

secrets-destroy:
	terraform -chdir=$(ROOT)/k8s/secrets destroy

secrets-decrypt:
	cd $(ROOT)/k8s/secrets && ./scripts/decrypt.sh

secrets-encrypt:
	cd $(ROOT)/k8s/secrets && ./scripts/encrypt.sh

helm:
	terraform -chdir=$(ROOT)/k8s/helm init
	terraform -chdir=$(ROOT)/k8s/helm apply $(TF_APPLY_FLAGS)

helm-destroy:
	terraform -chdir=$(ROOT)/k8s/helm destroy

fmt:
	terraform fmt -recursive infra/

kubeconfig:
	./scripts/get-kubeconfig.sh

all: doctor iam net compute kubeconfig secrets helm
	@echo ""
	@echo "==============================================="
	@echo " Bootstrap complete."
	@echo " Kubeconfig: $${KUBECONFIG_OUT:-$$HOME/.kube/k3s-harus}"
	@echo " Next: export KUBECONFIG=\$$HOME/.kube/k3s-harus"
	@echo "==============================================="

destroy-all: helm-destroy secrets-destroy compute-destroy net-destroy iam-destroy
