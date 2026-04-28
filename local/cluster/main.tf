resource "null_resource" "launch_k3s" {
  provisioner "local-exec" {
    command = <<EOF
      #!/usr/bin/env bash
      k3d cluster create ${local.cluster_name}
      k3d kubeconfig get ${local.cluster_name} > kubeconfig
    EOF
  }
}

resource "null_resource" "destroy_k3s" {
  triggers = {
    cluster_name = local.cluster_name
  }
  provisioner "local-exec" {
    when    = destroy
    command = <<EOF
      k3d cluster delete ${self.triggers.cluster_name}
      rm ./kubeconfig
    EOF
  }
}



locals {
  cluster_name = "local-forgejo"
}

