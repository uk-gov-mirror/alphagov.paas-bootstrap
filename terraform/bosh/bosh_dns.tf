resource "aws_route53_record" "bosh" {
  zone_id = "${var.system_dns_zone_id}"
  name    = "${var.bosh_fqdn}"
  type    = "A"
  ttl     = "60"
  records = ["${lookup(var.microbosh_ips, var.bosh_az)}"]
}

resource "aws_route53_record" "bosh-local" {
  zone_id = "${var.system_dns_zone_id}"
  name    = "bosh-local.${var.system_dns_zone_name}"
  type    = "A"
  ttl     = "60"
  records = ["127.0.0.1"]
}

resource "aws_route53_record" "bosh-uaa-local" {
  zone_id = "${var.system_dns_zone_id}"
  name    = "bosh-uaa-local.${var.system_dns_zone_name}"
  type    = "A"
  ttl     = "60"
  records = ["127.0.0.1"]
}


resource "aws_route53_record" "bosh-external" {
  zone_id = "${var.system_dns_zone_id}"
  name    = "${var.bosh_fqdn_external}"
  type    = "A"
  ttl     = "60"
  records = ["${aws_eip.bosh.public_ip}"]
}
