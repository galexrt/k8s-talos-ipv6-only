# k8s-talos-ipv6-only

Kubernetes: IPv6-only For Real In Good This Time. - https://galexrt.moe/blog/2025/kubernetes-ipv6-only-for-real-in-good-this-time

Primarily uses the following services/software:

- [Hetzner Cloud (HCloud)](https://www.hetzner.com/cloud/) - VMs (you might want to consider adding a Load Balancer for Kubernetes API access and/or exposing an Ingress controller)
- [NAT64/DNS64 resolver](https://nat64.net/) - IPv6 to IPv4 translation (to be able to pull container images/access from IPv4-only registries/services)
- [Packer](https://developer.hashicorp.com/packer) - Building and uploading Talos Linux images to HCloud
- [Terraform](https://developer.hashicorp.com/terraform) - Infrastructure as Code (IaC)
- [Talos Linux](https://www.talos.dev/) - Operating System, Kubernetes

## Directories & Files

- `packer/` - Packer configuration to build and upload Talos Linux image to Hetzner Cloud.
- `patches/` - Patches for Talos Linux to enable IPv6-only support.
- `values/` - Helm values for Cilium CNI and Talos Cloud Controller Manager (CCM).
- `.env.example` - Example environment file to set Hetzner Cloud API token.
- `terraform.tfvars.example` - Example Terraform variables file.
- `Makefile` - Makefile with convenience commands (not required, but can be helpful).
- `*.tf` - Terraform config/resource files.

## Requirements

- Hetzner Cloud Account with write access API token to a project
- Software installed:
    - Packer
    - Terraform
    - kubectl
    - talosctl

## Usage

1. Clone this repository

   ```bash
   git clone https://github.com/galexrt/k8s-talos-ipv6-only.git
   cd k8s-talos-ipv6-only
   ```
2. Configure the desired variables in `variables.tf` if you want to override the defaults. Copy and rename the file if you want to keep the original:

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   vim terraform.tfvars
   ```
3. Configure your Hetzner Cloud API token in the `.env` file. You can copy the example file and edit it:

   ```bash
   cp .env.example .env
   vim .env
   ```
4. Source the `.env` file to export the environment variables:

   ```bash
   source .env
   ```
5. Build and upload the Talos Linux image to Hetzner Cloud using Packer (file is in the `packer/` directory):

    ```bash
    cd packer/
	packer init .
	packer build .
    ```
6. Go back to the root directory and initialize and apply the Terraform configuration:

    ```bash
    cd ..
    terraform init
    terraform apply
    ```
7. After Terraform has finished, you can get the kubeconfig and talosconfig files from the output:

    ```bash
    terraform output --raw kubeconfig > ./kubeconfig
	terraform output --raw talosconfig > ./talosconfig
    ```
8. You can now use `kubectl` and `talosctl` with the generated configuration files:

    ```bash
    export KUBECONFIG=$(pwd)/kubeconfig
    export TALOSCONFIG=$(pwd)/talosconfig
    ```
9. Verify the cluster is up and running:

    ```bash
    kubectl get nodes
    ```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
