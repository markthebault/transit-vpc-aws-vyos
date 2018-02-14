
provider "aws" {
  version = "~> 1.9.0"
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
}
