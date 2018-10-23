resource "postgresql_role" "uaa" {
  name     = "uaa"
  login    = true
  password = "${var.secrets_bosh_uaa_postgres_password}"
}

resource "postgresql_database" "uaa" {
  name              = "uaa"
  owner             = "uaa"
  allow_connections = true
}
