output "address" {
    value = "${aws_elb.vault.dns_name}"
}

// Can be used to add additional SG rules to Vault instances.
output "vault_security_group" {
    value = "${aws_security_group.vault.id}"
}

// Can be used to add additional SG rules to the Vault ELB.
output "elb_security_group" {
    value = "${aws_security_group.elb.id}"
}

output "environment" {
  value = "${var.env}"
}

output "region" {
  value = "${var.region}"
}

output "vpc_cidr" {
  value = "${aws_vpc.vault.cidr_block}"
}

output "ssh_security_group" {
  value = "${aws_security_group.office-access-ssh.name}"
}

output "vpc_id" {
  value = "${aws_vpc.vault.id}"
}

output "subnet0_id" {
  value = "${aws_subnet.infra.0.id}"
}

output "zone0" {
  value = "${var.zones["zone0"]}"
}

output "zone1" {
  value = "${var.zones["zone1"]}"
}

output "infra_subnet_ids" {
  value = "${join(",", aws_subnet.infra.*.id)}"
}
