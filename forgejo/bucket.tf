resource "digitalocean_spaces_bucket" "forgejo_storage" {
  name   = "forgejotf-storage"
  region = "nyc3"
  acl    = "private"
}

resource "digitalocean_spaces_bucket" "forgejo_db_backup" {
  name   = "forgejotf-db-backup"
  region = "nyc3"
  acl    = "private"
}

