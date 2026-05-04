# This should be in a vpc because we are not savage animals
# So a vpc is expected to exist.
data "digitalocean_vpc" "existing" {
  name = var.VPC_NAME
}
