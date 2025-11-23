// Tokens & Secrets
variable "hcloud_token" {
  type        = string
  description = "The Hetzner Cloud API token."
  sensitive   = true
}

// Talos Cluster configuration
variable "cluster_name" {
  type        = string
  description = "The name of the Kubernetes cluster."
  default     = "mycool-k8s"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.34.2"
  description = "The Kubernetes version to use."
}

variable "talos_version" {
  type        = string
  description = "The Talos version to use."
  default     = "v1.11.5"
}

variable "cilium_cluster_id" {
  type        = number
  description = "The unique id for Cilium cluster mesh id."
  default     = 1
}

variable "datacenter_name" {
  type        = string
  description = "The name of the datacenter where the cluster is deployed."
  default     = "fsn1-dc14"
}

variable "control_plane_server_type" {
  type        = string
  description = "The server type for control plane nodes."
  default     = "cax11"

}

variable "control_plane_server_arch" {
  type        = string
  description = "The server architecture for control plane nodes."
  default     = "arm64"

}

// Worker nodes
variable "workers" {
  type = map(object({
    server_type = string
    name        = string
    // amd64 or arm64
    arch        = string
    location    = string
    labels      = map(string)
    // Example: `exampleTaint: exampleTaintValue:NoSchedule`
    taints      = map(string)
  }))
  description = "A map of worker node names to their server types."
  default     = {}
}

// Ingress LB
variable "lb_type" {
  type        = string
  description = "The type of the load balancer."
  default     = "lb11"

}

variable "lb_location" {
  type        = string
  description = "The location of the load balancer."
  default     = "fsn1"
}
