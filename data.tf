// Talos client config
data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints = [
    hcloud_primary_ip.controlplane_ip.ip_address
  ]
}

// HCloud datacenter + location info
data "hcloud_datacenter" "by_name" {
  name = var.datacenter_name
}

// HCloud image ids of Talos Linux (created by Packer)
data "hcloud_image" "arm" {
  with_selector     = "os=talos,version=${var.talos_version}"
  with_architecture = "arm"
  most_recent       = true
}

data "hcloud_image" "x86" {
  with_selector     = "os=talos,version=${var.talos_version}"
  with_architecture = "x86"
  most_recent       = true
}
