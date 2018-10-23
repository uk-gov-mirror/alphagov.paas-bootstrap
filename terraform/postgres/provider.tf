provider "postgresql" {
  host            = "${var.bosh_db_address}"
  port            = "${var.bosh_db_port}"
  database        = "${var.bosh_db_dbname}"
  username        = "${var.bosh_db_username}"
  password        = "${var.secrets_bosh_postgres_password}"
  sslmode         = "require"
  connect_timeout = 15
}
