terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
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

