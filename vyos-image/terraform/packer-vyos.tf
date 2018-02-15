# Generate file
data "template_file" "packer_script" {
    template = "${file("${path.module}/templates/run-packer.tmpl")}"


    vars {
      aws_region = "${var.aws_region}"
      vpc_id = "${module.vpc_vyos.vpc_id}"
      public_sub_id = "${module.vpc_vyos.public_subnets[0]}"
      vyos_base_ami = "${lookup(var.ami_ubuntu, var.aws_region)}"
    }
}
resource "null_resource" "packer_script" {
  triggers {
    template_rendered = "${ data.template_file.packer_script.rendered }"
  }
  provisioner "local-exec" {
    command = "echo '${ data.template_file.packer_script.rendered }' > ../run-packer"
  }
}
