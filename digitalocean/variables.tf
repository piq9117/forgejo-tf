variable "DIGITALOCEAN_BACKEND_BUCKET_ENDPOINT" {
  type = string
}

variable "DIGITALOCEAN_REGION" {
  type = string
}

variable "DIGITALOCEAN_BACKEND_BUCKET_NAME" {
  type = string
}

variable "DIGITALOCEAN_SPACES_ACCESS_ID" {
  type = string
}

variable "DIGITALOCEAN_SPACES_SECRET_KEY" {
  type = string
}

variable "DIGITALOCEAN_TOKEN" {
  type = string
}

variable "DROPLET_SIZE" {
  default = "s-2vcpu-2gb"
}

variable "SSH_PRIVATE_KEY_PATH" {
  type = string
}

variable "SSH_KEY_NAME" {
  type = string
}

variable "VPC_NAME" {
  type = string
}

variable "PORKBUN_API_KEY" {
  type = string
}

variable "PORKBUN_API_SECRET" {
  type = string
}

variable "ROOT_DOMAIN" {
  type = string
}

variable "SUB_DOMAIN" {
  type = string
}

