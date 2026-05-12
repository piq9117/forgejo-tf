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

resource "null_resource" "launch_k3ds" {
  provisioner "local-exec" {
    command = <<-EOF
    #!/usr/bin/env bash
    k3d cluster create ${local.cluster_name}
    k3d kubeconfig get ${local.cluster_name} > kubeconfig
    EOF
  }
}

resource "null_resource" "destroy_k3ds_cluster" {
  triggers = {
    cluster_name = local.cluster_name
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOF
    #!/usr/bin/env bash
    k3d cluster delete ${self.triggers.cluster_name}
    rm ./kubeconfig || true
    EOF
  }
}

locals {
  cluster_name = "forgejo"
}
