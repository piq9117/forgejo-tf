module "forgejo-runner" {
  source               = "../../forgejo-runner"
  FORGEJO_RUNNER_TOKEN = var.FORGEJO_RUNNER_TOKEN
  KUBECONFIG_PATH      = "../cluster/kubeconfig"
}
