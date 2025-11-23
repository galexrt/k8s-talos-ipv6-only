include .env
export

.PHONY: image
image:
	cd packer/ && \
		packer init . && \
		packer build .

.PHONY: apply
apply:
	terraform init || terraform init -upgrade
	terraform apply

	$(MAKE) output

.PHONY: output
output:
	terraform output --raw kubeconfig > ./kubeconfig
	terraform output --raw talosconfig > ./talosconfig
