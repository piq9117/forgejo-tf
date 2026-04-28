resource "helm_release" "forgejo_runner" {
  name       = "forgejo-runner"
  namespace  = "default"
  chart      = "forgejo-runner"
  repository = "oci://codeberg.org/wrenix/helm-charts"

  cleanup_on_fail = true
  atomic          = true

  set = [
    {
      name  = "runner.config.instance"
      value = "http://forgejo.default.svc.cluster.local:3000"
    },
    {
      name  = "runner.config.token"
      value = var.FORGEJO_RUNNER_TOKEN
    },

    {
      name  = "runner.config.name"
      value = "forgejo-runner"
    },
    { name  = "runner.config.type"
      value = "global"
    },
    {
      name  = "dind.enabled"
      value = "true"
    },
    {
      name  = "knownLastVersion"
      value = "true"
    }
  ]

  set_list = [{
    name = "runner.labels"
    value = [
      "ubuntu-latest:docker://ghcr.io/catthehacker/ubuntu:act-22.04",
    ]
  }]

  values = [yamlencode({
    dind = {
      image = {
        pullPolicy = "IfNotPresent"
      }
    }
    })
  ]
}

resource "null_resource" "destroy_secret_config" {
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete secret forgejo-runner-config -n default --ignore-not-found"
  }
}
