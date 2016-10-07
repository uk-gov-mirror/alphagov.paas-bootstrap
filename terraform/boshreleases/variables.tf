# SAH256 of the account IDs. To get it, run:
#
#   echo -n 1234567890 | sha256sum
#
# being 1234567890 the account id
variable "account_ids_sha256" {
  default = {
    "19cadd55dbfd1ec914844038f4089e612cbde5621351059a6c86aecbf1407eb9" = "ci"
  }
}

variable "aws_account" {
  default = "ci"
}

variable "region" {
  default = "eu-west-1"
}
