provider "aws" {
  region = "${var.region}"
}

resource "aws_vpc" "vault" {
  cidr_block = "${var.vpc_cidr}"

  tags {
    Name = "${var.env}-vault"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.vault.id}"
}

resource "aws_route_table" "infra" {
  vpc_id = "${aws_vpc.vault.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }
}

resource "aws_subnet" "infra" {
  count             = "${var.zone_count}"
  vpc_id            = "${aws_vpc.vault.id}"
  cidr_block        = "${lookup(var.infra_cidrs, format("zone%d", count.index))}"
  availability_zone = "${lookup(var.zones,       format("zone%d", count.index))}"
  depends_on        = ["aws_internet_gateway.default"]

  tags {
    Name = "${var.env}-infra-${lookup(var.zones, format("zone%d", count.index))}"
  }
}

resource "aws_route_table_association" "infra" {
  count          = "${var.zone_count}"
  subnet_id      = "${element(aws_subnet.infra.*.id, count.index)}"
  route_table_id = "${aws_route_table.infra.id}"
}

resource "aws_security_group" "office-access-ssh" {
  vpc_id      = "${aws_vpc.vault.id}"
  name        = "${var.env}-office-access-ssh"
  description = "Allow access from office"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${compact(concat(var.admin_cidrs, list(var.vagrant_cidr)))}"]
  }

  tags {
    Name = "${var.env}-office-access-ssh"
  }
}
