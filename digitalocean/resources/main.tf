terraform {
  # this bucket is expected to exist before running this block
  backend "s3" {
    endpoints = {
      s3 = var.DIGITALOCEAN_BACKEND_BUCKET_ENDPOINT
    }
    # fake region. will get aws error if digitalocean region is used
    region = "us-east-1"
    bucket = var.FORGEJO_BACKEND_BUCKET_NAME
    key    = "forgejo-cluster-resources/terraform.tfstate"
    #
    skip_credentials_validation = true
    access_key                  = var.DIGITALOCEAN_SPACES_ACCESS_ID
    secret_key                  = var.DIGITALOCEAN_SPACES_SECRET_KEY
  }
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.1.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"

    }

    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.85.0"
    }

  }
}

provider "helm" {
  kubernetes = {
    config_path = local.kubeconfig_path
  }
}

provider "kubernetes" {
  config_path = local.kubeconfig_path
}

provider "kubectl" {
  config_path = local.kubeconfig_path
}

locals {
  kubeconfig_path = "../kubeconfig"
}

provider "digitalocean" {
  token             = var.DIGITALOCEAN_TOKEN
}
