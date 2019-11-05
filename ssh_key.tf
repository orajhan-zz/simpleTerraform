resource "null_resource" "ssh_key_copy_to_Bastion" {
  depends_on = ["oci_core_instance.Bastion"]

  connection {
    agent       = false
    timeout     = "30m"
    host        = "${oci_core_instance.Bastion.public_ip}"
    user        = "opc"
    private_key = "${file(var.compute_ssh_private_key)}"

  }
  provisioner "file" {
    source = "id_rsa"
    destination = "~/.ssh/id_rsa"
  }
  provisioner "remote-exec" {
    inline = ["chmod 600 ~/.ssh/id_rsa"]
  }
}
