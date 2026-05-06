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
            name = "FORGEJO____APP_NAME"
            value = "piq"
          }
          env {
            name = "FORGEJO____APP_SLOGAN"
            value = "nothing gay happening here"
          }

          env {
            name  = "FORGEJO__security__INSTALL_LOCK"
            value = "true"
          }

          env {
            name  = "FORGEJO__server__ROOT_URL"
            value = "https://${var.SUB_DOMAIN}.${var.ROOT_DOMAIN}"
          }

          env {
            name  = "FORGEJO__server__SSH_DOMAIN"
            value = "${var.SUB_DOMAIN}.${var.ROOT_DOMAIN}"
          }

          env {
            name  = "FORGEJO__server__START_SSH_SERVER"
            value = "true"
          }

          env {
            name  = "FORGEJO__server__SSH_PORT"
            value = "2222"
          }
          env {
            name  = "FORGEJO__server__SSH_LISTEN_PORT"
            value = "2222"
          }

          env {
            name  = "FORGEJO__service__DISABLE_REGISTRATION"
            value = "true"
          }

          env {
            name  = "FORGEJO__storage__STORAGE_TYPE"
            value = "minio"
          }

          env {
            name  = "FORGEJO__storage__MINIO_USE_SSL"
            value = "true"
          }

          env {
            name  = "FORGEJO__storage__MINIO_ENDPOINT"
            value = var.FORGEJO_BUCKET_ENDPOINT
          }

          env {
            name  = "FORGEJO__storage__MINIO_ACCESS_KEY_ID"
            value = var.FORGEJO_BUCKET_ACCESS_ID
          }

          env {
            name  = "FORGEJO__storage__MINIO_SECRET_ACCESS_KEY"
            value = var.FORGEJO_BUCKET_SECRET_ACCESS_KEY
          }

          env {
            name  = "FORGEJO__storage__MINIO_BUCKET"
            value = var.FORGEJO_BUCKET_NAME
          }

          env {
            name  = "FORGEJO__storage__MINIO_LOCATION"
            value = var.FORGEJO_BUCKET_REGION
          }

          env {
            name  = "FORGEJO__attachment__MINIO_BASE_PATH"
            value = "attachments/"
          }

          env {
            name  = "FORGEJO__lfs__MINIO_BASE_PATH"
            value = "lfs/"
          }

          env {
            name  = "FORGEJO__avatar__MINIO_BASE_PATH"
            value = "avatars/users/"
          }

          env {
            name  = "FORGEJO__repo-avatar__MINIO_BASE_PATH"
            value = "avatars/repositories/"
          }

          env {
            name  = "FORGEJO__repo-archive__MINIO_BASE_PATH"
            value = "archives/"
          }
          env {

            name  = "FORGEJO__packages__MINIO_BASE_PATH"
            value = "packages/"
          }

          env {
            name  = "FORGEJO__storage.actions_log__MINIO_BASE_PATH"
            value = "actions/logs"
          }

          env {
            name  = "FORGEJO__actions.artifacts__MINIO_BASE_PATH"
            value = "actions/artifacts/"
          }

          port {
            container_port = 3000
          }

          port {
            container_port = 2222
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
  depends_on = [
    kubernetes_persistent_volume_claim_v1.forgejo_data,
    digitalocean_spaces_bucket.forgejo_storage
  ]
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
      port        = 80
      target_port = 3000
    }

    port {
      name        = "ssh"
      port        = 2222
      target_port = 2222
    }

    type                    = "LoadBalancer"
    external_traffic_policy = "Local"

    external_ips = [var.INSTANCE_IP]

  }
}

resource "kubernetes_ingress_v1" "forgejo" {
  metadata {
    name      = "forgejo"
    namespace = "default"
    annotations = {
      "traefik.ingress.kubernetes.io/router.tls" = "true"
    }
  }

  spec {
    rule {
      host = "${var.SUB_DOMAIN}.${var.ROOT_DOMAIN}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.forgejo.metadata[0].name
              port {
                number = 80
              }
            }
          }

        }
      }
    }
    tls {
      hosts       = ["${var.SUB_DOMAIN}.${var.ROOT_DOMAIN}"]
      secret_name = "forgejo-repo-tls"
    }
  }
}

resource "kubernetes_manifest" "certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "forgejo-repo-tls"
      namespace = "default"
    }

    spec = {
      secretName = "forgejo-repo-tls"
      dnsNames   = ["${var.SUB_DOMAIN}.${var.ROOT_DOMAIN}"]
      issuerRef = {
        name = "letsencrypt"
        kind = "ClusterIssuer"
      }
    }
  }
}

resource "kubernetes_manifest" "letsencrypt" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = var.ADMIN_EMAIL
        privateKeySecretRef = {
          name = "letsencrypt"
        }
        solvers = [
          {
            http01 = {
              ingress = {
                class = "traefik"
              }
            }
          }
        ]
      }
    }
  }
}

resource "kubernetes_manifest" "traefik_config" {
  manifest = {
    apiVersion = "helm.cattle.io/v1"
    kind       = "HelmChartConfig"
    metadata = {
      name      = "traefik"
      namespace = "kube-system"
    }
    spec = {
      valuesContent = <<-YAML
        logs:
          access:
            enabled: true
            format: json
            fields:
              headers:
                defaultMode: keep

      YAML
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "forgejo_data" {
  metadata {
    name = "forgejo-data"
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = { storage = "10Gi" }
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
          name  = "forgejo-admin"
          image = "codeberg.org/forgejo/forgejo:14"
          command = [
            "forgejo", "admin", "user", "create", "--admin",
            "--username", var.ADMIN_USERNAME,
            "--password", var.ADMIN_PASSWORD,
            "--email", var.ADMIN_EMAIL,
            "--config", "/data/gitea/conf/app.ini"
          ]

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

resource "kubernetes_secret_v1" "bucket_credentials" {
  metadata {
    name      = "bucket-credentials"
    namespace = "default"
  }
  data = {
    cloud = <<EOF
    [default]
    aws_access_key_id = ${var.DIGITALOCEAN_SPACES_ACCESS_ID}
    aws_secret_access_key = ${var.DIGITALOCEAN_SPACES_SECRET_KEY}
    EOF
  }
}

resource "helm_release" "velero" {
  name       = "velero"
  repository = "https://vmware-tanzu.github.io/helm-charts"
  chart      = "velero"
  namespace  = "default"

  set = [{
    name  = "configuration.backupStorageLocation[0].provider"
    value = "aws"
    },
    {
      name  = "configuration.backupStorageLocation[0].name"
      value = "default"
    },
    {
      name  = "configuration.backupStorageLocation[0].bucket"
      value = digitalocean_spaces_bucket.forgejo_db_backup.name
    },
    {
      name  = "configuration.backupStorageLocation[0].config.region"
      value = "nyc3"
    },
    {
      name  = "configuration.backupStorageLocation[0].config.s3Url",
      value = "https://nyc3.digitaloceanspaces.com"
    },
    {
      name  = "credentials.existingSecret",
      value = kubernetes_secret_v1.bucket_credentials.metadata[0].name
    },
    {
      name  = "configuration.volumeSnapshotLocation[0].name"
      value = "default"
    },
    {
      name  = "configuration.volumeSnapshotLocation[0].provider"
      value = "aws"
    },
    { name = "plugins.aws.enabled", value = "true" },
    { name = "initContainers[0].name", value = "velero-plugin-for-aws" },
    { name = "initContainers[0].image", value = "velero/velero-plugin-for-aws:v1.10.0" },
    { name = "initContainers[0].volumeMounts[0].mountPath", value = "/target" },
    { name = "initContainers[0].volumeMounts[0].name", value = "plugins" },

  ]
  depends_on = [digitalocean_spaces_bucket.forgejo_db_backup]
}

resource "kubernetes_manifest" "velero_daily_schedule" {
  manifest = {
    apiVersion = "velero.io/v1"
    kind       = "Schedule"
    metadata = {
      name      = "daily-velero"
      namespace = "default"
    }
    spec = {
      schedule = "0 2 * * *"
      template = {
        includedNamespaces = ["default"]
        snapshotVolumes    = true
        ttl                = "720h"
      }
    }
  }
}

output "forgejo_location" {
  value = kubernetes_ingress_v1.forgejo.status[0].load_balancer[0].ingress[0].ip
}

