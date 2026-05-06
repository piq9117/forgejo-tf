module "forgejo_domain" {
  source             = "../domain"
  PORKBUN_API_KEY    = var.PORKBUN_API_KEY
  PORKBUN_API_SECRET = var.PORKBUN_API_SECRET

  ROOT_DOMAIN  = var.ROOT_DOMAIN
  SUB_DOMAIN   = var.SUB_DOMAIN
  IPV4_ADDRESS = digitalocean_droplet.forgejo.ipv4_address
}
