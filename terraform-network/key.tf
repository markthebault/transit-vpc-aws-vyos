resource "aws_key_pair" "mth_kp" {
  key_name   = "mth-key"
  public_key = "${file("${var.key_pair_public_path}")}"
}
