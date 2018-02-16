# Generate file
data "template_file" "vpn_ssh" {
    template = "${file("${path.module}/templates/ssh-config.tmpl")}"

    vars {
        vyos_public_ip = "${aws_eip.vyos_instance.public_ip}"
        vyos_user = "${var.vyos_user}"
        key_pair_private_path = "${var.key_pair_private_path}"
    }
}


resource "null_resource" "ssh_conf" {
  triggers {
    template_rendered = "${ data.template_file.vpn_ssh.rendered }"
  }
  provisioner "local-exec" {
    command = "echo '${ data.template_file.vpn_ssh.rendered }' > ../vpn-generated-configurations/ssh-config"
  }
}
