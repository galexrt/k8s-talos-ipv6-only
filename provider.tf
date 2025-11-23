provider "helm" {
  kubernetes = {
    host                   = talos_cluster_kubeconfig.this.kubernetes_client_configuration.host
    client_certificate     = talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_certificate
    client_key             = talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_key
    cluster_ca_certificate = talos_cluster_kubeconfig.this.kubernetes_client_configuration.ca_certificate
  }
}

provider "kubectl" {
  host                   = talos_cluster_kubeconfig.this.kubernetes_client_configuration.host
  client_certificate     = talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_certificate
  client_key             = talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_key
  cluster_ca_certificate = talos_cluster_kubeconfig.this.kubernetes_client_configuration.ca_certificate
  load_config_file       = false
  apply_retry_count      = 3
}

provider "hcloud" {
  token = var.hcloud_token
}

provider "kubernetes" {
  host                   = talos_cluster_kubeconfig.this.kubernetes_client_configuration.host
  client_certificate     = talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_certificate
  client_key             = talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_key
  cluster_ca_certificate = talos_cluster_kubeconfig.this.kubernetes_client_configuration.ca_certificate
}

provider "talos" {}
