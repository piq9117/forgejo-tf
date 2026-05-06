terraform {
  required_providers {
    porkbun = {
      source  = "marcfrederick/porkbun"
      version = ">= 0.1.0"
    }
  }
}

provider "porkbun" {
  api_key        = var.PORKBUN_API_KEY
  secret_api_key = var.PORKBUN_API_SECRET
}

resource "porkbun_dns_record" "repo_domain" {
  domain    = var.ROOT_DOMAIN
  type      = "A"
  subdomain = var.SUB_DOMAIN
  content   = var.IPV4_ADDRESS
}
