# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = "${var.tenancy_ocid}"
}

# Gets a list of vNIC attachments on the instance
data "oci_core_vnic_attachments" "Bastion_Vnics" {
  compartment_id      = "${var.compartment_ocid}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1],"name")}"
  instance_id         = "${oci_core_instance.Bastion.id}"
}

data "oci_core_vnic_attachments" "APACPursuit_Instance_Vnics" {
  compartment_id      = "${var.compartment_ocid}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1],"name")}"
  instance_id         = "${oci_core_instance.APACPursuit_Instance.id}"
}

data "oci_audit_events" "audit_events" {
  compartment_id = "${var.compartment_ocid}"
  start_time = "${timeadd(timestamp(), "-5m")}"
  end_time = "${timestamp()}"
}


# Gets the OCID of the first (default) vNIC
data "oci_core_vnic" "Bastion_Vnic" {
  vnic_id = "${lookup(data.oci_core_vnic_attachments.Bastion_Vnics.vnic_attachments[0],"vnic_id")}"
}

data "oci_core_vnic" "APACPursuit_Instance_Vnic" {
  vnic_id = "${lookup(data.oci_core_vnic_attachments.APACPursuit_Instance_Vnics.vnic_attachments[0],"vnic_id")}"
}
