packer {
  required_plugins {
    hcloud = {
      source  = "github.com/hetznercloud/hcloud"
      version = "1.7.0"
    }
  }
}

variable "talos_version" {
  type    = string
  default = "v1.11.5"
}

variable "variant" {
  type    = string
  default = "hcloud"
}

variable "schematic_id" {
  type    = string
  # From https://factory.talos.dev/
  default = "376567988ad370138ad8b2698212367b8edcb69b5fd68c80be1f2ec7d603b4ba"
}

variable "server_location" {
  type    = string
  default = "fsn1"
}

source "hcloud" "talos-amd64" {
  rescue       = "linux64"
  image        = "debian-12"
  location     = "${var.server_location}"
  server_type  = "cpx11"
  ssh_username = "root"

  snapshot_name   = "talos system disk - amd64 - ${var.talos_version}"
  snapshot_labels = {
    type    = "infra",
    os      = "talos",
    version = "${var.talos_version}",
    arch    = "amd64",
  }
}

source "hcloud" "talos-arm64" {
  rescue       = "linux64"
  image        = "debian-12"
  location     = "${var.server_location}"
  server_type  = "cax11"
  ssh_username = "root"

  snapshot_name   = "talos system disk - arm64 - ${var.talos_version}"
  snapshot_labels = {
    type    = "infra",
    os      = "talos",
    version = "${var.talos_version}",
    arch    = "arm64",
  }
}

build {
  sources = [
    "source.hcloud.talos-amd64",
    "source.hcloud.talos-arm64",
  ]

  provisioner "shell" {
    inline = [
      "echo Architecture: $(uname -m)",
      "apt-get install -q -y wget",
      # Don't question it, that's how I made it work and I'm happy that it works..
      "wget -O /tmp/talos.raw.xz \"https://factory.talos.dev/image/${var.schematic_id}/${var.talos_version}/${var.variant}-$(test \"$(uname -m)\" = 'aarch64' && echo -n 'arm64' || echo -n 'amd64').raw.xz\"",
      "xz -d -c /tmp/talos.raw.xz | dd of=/dev/sda && sync",
    ]
  }
}
