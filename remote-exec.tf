resource "null_resource" "remote-exec" {
  depends_on = ["oci_core_instance.APACPursuit_Instance"]

  connection {
    agent       = false
    timeout     = "30m"
    host        = "${oci_core_instance.APACPursuit_Instance.private_ip}"
    user        = "opc"
    private_key = "${file(var.compute_ssh_private_key)}"

    bastion_host        = "${oci_core_instance.Bastion.public_ip}"
    bastion_user        = "opc"
    bastion_private_key = "${file(var.compute_ssh_private_key)}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo -e attach volume",
      "sudo iscsiadm -m node -o new -T ${oci_core_volume_attachment.TFBlockAttach.iqn} -p ${oci_core_volume_attachment.TFBlockAttach.ipv4}:${oci_core_volume_attachment.TFBlockAttach.port}",
      "sudo iscsiadm -m node -o update -T ${oci_core_volume_attachment.TFBlockAttach.iqn} -n node.startup -v automatic",
      "sudo iscsiadm -m node -T ${oci_core_volume_attachment.TFBlockAttach.iqn} -p ${oci_core_volume_attachment.TFBlockAttach.ipv4}:${oci_core_volume_attachment.TFBlockAttach.port} -l",
      "echo -e Mounting block storage",
      "sudo mkfs -F -t ext4 /dev/sdb",
      "sudo mkdir /apacpursuit",
      "sudo mount /dev/sdb /apacpursuit",
      "sudo chown -R opc:opc /apacpursuit",
      "sudo sh /tmp/iscsiAttach.sh",
      "sudo yum install docker-engine -y",
      "sudo setenforce 0",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "sudo usermod -a -G docker opc",
      "sudo curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "sudo docker run -d -p 5000:5000 --restart=always --name registry registry:2",
      "sudo docker run -d -p 5001:80 -e ENV_DOCKER_REGISTRY_HOST=localhost -e ENV_DOCKER_REGISTRY_PORT=5000 konradkleine/docker-registry-frontend:v2",
      "sudo docker run -d -p 5002:9000 --restart always -v /var/run/docker.sock:/var/run/docker.sock -v /opt/portainer:/data portainer/portainer"
    ]
  }

}
