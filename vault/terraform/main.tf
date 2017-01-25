resource "template_file" "install" {
    template = "${file("${path.module}/scripts/install.sh.tpl")}"

    vars {
        download_url  = "${var.download-url}"
        config        = <<EOF
backend "s3" {
  bucket     = "gds-paas-${var.env}-state"
  access_key = ""
  secret_key = ""
  region     = "eu-west-1"
}

listener "tcp" {
  address     = "127.0.0.1:8200"
  tls_disable = 1
}
EOF
        extra-install = "${var.extra-install}"
    }
}

// We launch Vault into an ASG so that it can properly bring them up for us.
resource "aws_autoscaling_group" "vault" {
    name = "vault - ${aws_launch_configuration.vault.name}"
    launch_configuration = "${aws_launch_configuration.vault.name}"
    availability_zones = ["${split(",", var.availability-zones)}"]
    min_size = "${var.nodes}"
    max_size = "${var.nodes}"
    desired_capacity = "${var.nodes}"
    health_check_grace_period = 15
    health_check_type = "EC2"
    vpc_zone_identifier = ["${aws_subnet.infra.*.id}"]
    load_balancers = ["${aws_elb.vault.id}"]

    tag {
        key = "Name"
        value = "vault"
        propagate_at_launch = true
    }
}

resource "aws_launch_configuration" "vault" {
    image_id = "${var.ami}"
    instance_type = "${var.instance_type}"
    key_name = "${var.key-name}"
    security_groups = ["${aws_security_group.vault.id}"]
    user_data = "${template_file.install.rendered}"
    associate_public_ip_address = true
    iam_instance_profile = "${aws_iam_instance_profile.vault.id}"
}

// Security group for Vault allows SSH and HTTP access (via "tcp" in
// case TLS is used)
resource "aws_security_group" "vault" {
    name = "vault"
    description = "Vault servers"
    vpc_id = "${aws_vpc.vault.id}"
}

resource "aws_security_group_rule" "vault-ssh" {
    security_group_id = "${aws_security_group.vault.id}"
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

// This rule allows Vault HTTP API access to individual nodes, since each will
// need to be addressed individually for unsealing.
resource "aws_security_group_rule" "vault-http-api" {
    security_group_id = "${aws_security_group.vault.id}"
    type = "ingress"
    from_port = 8200
    to_port = 8200
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "vault-egress" {
    security_group_id = "${aws_security_group.vault.id}"
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}
