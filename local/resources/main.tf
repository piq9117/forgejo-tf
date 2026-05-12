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
  }
}

provider "helm" {
  kubernetes = {
    config_path = "../kubeconfig"
  }
}

provider "kubernetes" {
  config_path = "../kubeconfig"
}

