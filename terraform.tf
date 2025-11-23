terraform {
  required_version = ">=1.8.0"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.17.0"
    }

    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.1.3"
    }

    github = {
      source  = "integrations/github"
      version = "6.6.0"
    }

    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.51.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.37.1"
    }

    talos = {
      source  = "siderolabs/talos"
      version = "0.9.0"
    }
  }
}
