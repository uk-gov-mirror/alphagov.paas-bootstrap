resource "aws_iam_role" "vault" {
  name               = "vault"
  assume_role_policy = "${file("${path.module}/policies-json/ec2_assume_role.json")}"
}

resource "aws_iam_instance_profile" "vault" {
  name  = "vault"
  roles = ["${aws_iam_role.vault.name}"]
}

resource "aws_iam_policy" "vault_manage_state_s3_buckets" {
  name        = "VaultManageStateS3Buckets"
  description = "Permissions for to manage S3 state buckets"
  policy      = "${file("${path.module}/policies-json/manage_state_s3_buckets.json")}"
}

resource "aws_iam_role_policy_attachment" "vault_manage_state_s3_buckets" {
  role       = "${aws_iam_role.vault.name}"
  policy_arn = "${aws_iam_policy.vault_manage_state_s3_buckets.arn}"
}
