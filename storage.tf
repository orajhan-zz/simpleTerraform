resource "oci_core_volume" "TFBlock0" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "${var.InstanceName}-tf-volume"
  size_in_gbs         = "200"
}

resource "oci_core_volume_attachment" "TFBlockAttach" {
  attachment_type = "iscsi"
  instance_id     = "${oci_core_instance.APACPursuit_Instance.id}"
  volume_id       = "${oci_core_volume.TFBlock0.id}"
}
