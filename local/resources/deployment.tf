resource "kubernetes_deployment_v1" "forgejo" {
  metadata {
    name = "forgejo"
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "forgejo"
      }
    }

    template {
      metadata {
        labels = {
          app = "forgejo"
        }
      }

      spec {
        container {
          image = "codeberg.org/forgejo/forgejo:14"
          name  = "forgejo"

          env {
            name  = "USER_UID"
            value = 1000
          }

          env {
            name  = "USER_GID"
            value = 1000
          }

          env {
            name  = "FORGEJO__security__INSTALL_LOCK"
            value = "true"
          }

          env {
            name  = "FORGEJO__server__ROOT_URL"
            value = "http://${kubernetes_service_v1.forgejo.status[0].load_balancer[0].ingress[0].ip}:3000"
          }

          port {
            container_port = 3000
          }

          port {
            container_port = 22
          }

          volume_mount {
            name       = "data"
            mount_path = "/data"
          }

          volume_mount {
            name       = "localtime"
            mount_path = "/etc/localtime"
            read_only  = true
          }
        }

        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.forgejo_data.metadata[0].name
          }
        }

        volume {
          name = "localtime"
          host_path {
            path = "/etc/localtime"
            type = "FileOrCreate"
          }
        }
      }
    }
  }

  depends_on = [kubernetes_persistent_volume_claim_v1.forgejo_data]
}

resource "kubernetes_service_v1" "forgejo" {
  metadata {
    name = "forgejo"
  }

  spec {
    selector = {
      app = "forgejo"
    }

    port {
      name        = "http"
      port        = 3000
      target_port = 3000
    }

    port {
      name        = "ssh"
      port        = 22
      target_port = 22
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_persistent_volume_claim_v1" "forgejo_data" {
  metadata {
    name = "forgejo-data"
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }

  wait_until_bound = false
}

resource "kubernetes_job_v1" "forgejo_admin" {
  metadata {
    name = "forgejo-admin-create"
  }

  spec {
    template {
      metadata {
        name = "forgejo-admin-create"
      }

      spec {
        container {
          name    = "forge-admin"
          image   = "codeberg.org/forgejo/forgejo:14"
          command = ["forgejo", "admin", "user", "create", "--admin", "--username", var.ADMIN_USERNAME, "--password", var.ADMIN_PASSWORD, "--email", var.ADMIN_EMAIL, "--config", "/data/gitea/conf/app.ini"]

          security_context {
            run_as_user  = 1000
            run_as_group = 1000
          }

          volume_mount {
            name       = "data"
            mount_path = "/data"
          }
        }

        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.forgejo_data.metadata[0].name
          }
        }
        restart_policy = "Never"
      }
    }
  }

  depends_on = [kubernetes_deployment_v1.forgejo]
}

output "cluster_ip" {
  value = kubernetes_service_v1.forgejo.spec[0].cluster_ip
}

output "load_balancer_ip" {
  value = kubernetes_service_v1.forgejo.status[0].load_balancer[0].ingress[0].ip
}
