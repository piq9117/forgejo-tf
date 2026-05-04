data "digitalocean_ssh_key" "default" {
  name = var.SSH_KEY_NAME
}

resource "digitalocean_droplet" "forgejo" {
  image      = "ubuntu-22-04-x64"
  name       = "forgejo-node"
  region     = var.DIGITALOCEAN_REGION
  size       = var.DROPLET_SIZE
  ssh_keys   = [data.digitalocean_ssh_key.default.id]
  monitoring = true
  vpc_uuid   = data.digitalocean_vpc.existing.id

  provisioner "remote-exec" {
    inline = [
      "apt-get update",
      "apt-get install -y ca-certificate curl",
      "curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='server --write-kubeconfig-mode 644' sh -",
      "echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> ~/.bashrc",
    ]

    connection {
      type        = "ssh"
      user        = "root"
      private_key = file(var.SSH_PRIVATE_KEY_PATH)
      host        = self.ipv4_address
    }
  }

}

resource "null_resource" "after_destroy_cluster" {
  provisioner "local-exec" {
    when    = destroy
    command = "rm ./kubeconfig || true"
  }
}

output "droplet_ip" {
  value = digitalocean_droplet.forgejo.ipv4_address
}

output "kubeconfig_copy_command" {
  value = "scp root@${digitalocean_droplet.forgejo.ipv4_address}:/etc/rancher/k3s/k3s.yaml ./kubeconfig"
}
