terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.1.0"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.85.0"
    }
  }
}

provider "helm" {
  kubernetes = {
    config_path = var.KUBECONFIG_PATH
  }
}

provider "kubernetes" {
  config_path = var.KUBECONFIG_PATH
}

provider "digitalocean" {
  token             = var.DIGITALOCEAN_TOKEN
  spaces_access_id  = var.DIGITALOCEAN_SPACES_ACCESS_ID
  spaces_secret_key = var.DIGITALOCEAN_SPACES_SECRET_KEY
}
