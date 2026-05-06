module "forgejo_runner" {
  source               = "../../forgejo-runner"
  FORGEJO_RUNNER_TOKEN = var.FORGEJO_RUNNER_TOKEN
  KUBECONFIG_PATH      = "../kubeconfig"
}

variable "FORGEJO_RUNNER_TOKEN" {
  type = string
}
