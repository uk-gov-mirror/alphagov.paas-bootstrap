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

resource "aws_iam_policy" "get_instance_profile" {
  name        = "GetInstanceProfile"
  description = "Retrieves information about the specified instance profile, including the instance profile's path, GUID, ARN, and role."
  policy      = "${file("${path.module}/policies-json/get_instance_profile.json")}"
}

resource "aws_iam_role_policy_attachment" "vault_get_instance_profile" {
  role       = "concourse-lite"
  policy_arn = "${aws_iam_policy.get_instance_profile.arn}"
}
