resource "talos_machine_secrets" "this" {
  talos_version = var.talos_version
}

// Control Plane IP + Server
resource "hcloud_primary_ip" "controlplane_ip" {
  name          = "${var.cluster_name}-control-plane-1"
  datacenter    = var.datacenter_name
  type          = "ipv6"
  assignee_type = "server"
  auto_delete   = true
  labels = {
    "hallo" : "welt"
  }

  depends_on = [
    data.hcloud_datacenter.by_name,
  ]
}

locals {
  template_vars = {
    endpoint    = hcloud_primary_ip.controlplane_ip.ip_address
    clusterName = var.cluster_name
    hcloudToken = var.hcloud_token
  }
}

// Create controlplane talos config
data "talos_machine_configuration" "controlplane" {
  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${hcloud_primary_ip.controlplane_ip.ip_address}:6443"
  machine_type       = "controlplane"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
  config_patches = [
    templatefile("${path.module}/patches/all.yaml", local.template_vars),
    templatefile("${path.module}/patches/registries.yaml", local.template_vars),
    templatefile("${path.module}/patches/controlplane.yaml", local.template_vars)
  ]
}

resource "hcloud_server" "controlplane_server" {
  name        = "${var.cluster_name}-control-plane-1"
  image       = var.control_plane_server_arch == "arm64" ? data.hcloud_image.arm.id : data.hcloud_image.x86.id
  server_type = var.control_plane_server_type
  datacenter  = var.datacenter_name
  labels = {
    cluster: var.cluster_name
    type:    "control-plane"
  }
  user_data = data.talos_machine_configuration.controlplane.machine_configuration
  public_net {
    ipv4_enabled = false
    ipv6_enabled = true
    ipv6 = hcloud_primary_ip.controlplane_ip.id
  }

  depends_on = [
    talos_machine_secrets.this,
  ]
}

// Kubeconfig
resource "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = hcloud_server.controlplane_server.ipv6_address
}

// Bootstrap Cluster
resource "talos_machine_bootstrap" "bootstrap" {
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoint             = hcloud_server.controlplane_server.ipv4_address
  node                 = hcloud_server.controlplane_server.ipv4_address
}

// Create Worker servers
data "talos_machine_configuration" "worker" {
  for_each = var.workers

  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${hcloud_primary_ip.controlplane_ip.ip_address}:6443"
  machine_type       = "worker"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
  docs               = false
  examples           = false
  config_patches = [
    templatefile("${path.module}/patches/all.yaml", local.template_vars),
    templatefile("${path.module}/patches/registries.yaml", local.template_vars),
    templatefile("${path.module}/templates/worker.yaml", local.template_vars),
    yamlencode({
      machine = {
        nodeLabels = each.value.labels
        nodeTaints = each.value.taints
      }
    })
  ]
}

resource "hcloud_server" "worker_server" {
  for_each    = var.workers

  name        = each.value.name
  image       = each.value.arch == "arm64" ? data.hcloud_image.arm.id : data.hcloud_image.x86.id
  server_type = each.value.server_type
  location    = each.value.location
  labels      = { type = "talos-worker" }
  user_data   = data.talos_machine_configuration.worker[each.key].machine_configuration
  public_net {
    ipv4_enabled = false
    ipv6_enabled = true
  }
}

// Install Talos Cloud Controller Manager and Cilium using Helm
resource "helm_release" "talos_cloud_controller_manager" {
  name       = "talos-cloud-controller-manager"
  namespace  = "kube-system"
  chart      = "oci://ghcr.io/siderolabs/charts/talos-cloud-controller-manager"
  version    = "0.5.2"
  values     = [file("${path.module}/values/talos-ccm-values.yaml")]
}

resource "helm_release" "cilium" {
  name       = "cilium"
  namespace  = "kube-system"
  chart      = "cilium/cilium"
  version    = "1.18.2"
  values     = [file("${path.module}/values/cilium-values.yaml")]
}
