resource "oci_core_instance" "APACPursuit_Instance" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "${var.InstanceName}"
  shape               = "${var.InstanceShape}"
  source_details {
        #Required
        source_id = "${var.InstanceImageOCID[var.region]}"
        source_type = "image"
    }

  create_vnic_details {
    subnet_id        = "${oci_core_subnet.APACPursuit_Private_Subnet.id}"
    display_name     = "PrimaryVNIC"
    assign_public_ip = false
    hostname_label   = "${var.InstanceName}"
  }

  metadata =  {
    ssh_authorized_keys = "${file(var.compute_ssh_public_key)}"
  }

  timeouts {
    create = "60m"
  }
}


resource "oci_core_instance" "Bastion" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "Bastion_host"
  shape               = "${var.BastionShape}"
  source_details {
        #Required
        source_id = "${var.InstanceImageOCID[var.region]}"
        source_type = "image"
    }

  create_vnic_details {
    subnet_id        = "${oci_core_subnet.APACPursuit_Public_Subnet.id}"
    display_name     = "PrimaryVNIC"
    assign_public_ip = true
    hostname_label   = "${var.Bastion}"
  }

  metadata =  {
    ssh_authorized_keys = "${file(var.compute_ssh_public_key)}"
  }

  timeouts {
    create = "60m"
  }
}
