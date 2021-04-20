resource "aws_eip" "concourse" {
  count = var.web_instances
  name = "concourse_ip.${count.index}"
  vpc = true
}

