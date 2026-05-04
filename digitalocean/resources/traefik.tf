data "http" "traefik_crds" {
  url = "https://raw.githubusercontent.com/traefik/traefik/v3.6/docs/content/reference/dynamic-configuration/kubernetes-crd-definition-v1.yml"
}

resource "kubectl_manifest" "traefik_crds" {
  yaml_body = data.http.traefik_crds.response_body
}

data "http" "traefik_rbac" {
  url = "https://raw.githubusercontent.com/traefik/traefik/v3.6/docs/content/reference/dynamic-configuration/kubernetes-crd-rbac.yml"
}

resource "kubectl_manifest" "traefik_rbac" {
  yaml_body = data.http.traefik_rbac.response_body
}

