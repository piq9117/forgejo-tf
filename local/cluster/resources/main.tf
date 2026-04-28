module "forgejo" {
  source          = "../../../forgejo"
  ADMIN_USERNAME  = var.ADMIN_USERNAME
  ADMIN_PASSWORD  = var.ADMIN_PASSWORD
  ADMIN_EMAIL     = var.ADMIN_EMAIL
  KUBECONFIG_PATH = "../kubeconfig"
}

output "app_location" {
  value = "http://${module.forgejo.load_balancer_ip}:3000"
}
