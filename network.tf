resource "oci_core_virtual_network" "APACPursuitVCN" {
  cidr_block     = "10.1.0.0/16"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "APACPursuitVCN"
  dns_label      = "APACPursuitVCN"
}

resource "oci_core_subnet" "APACPursuit_Public_Subnet" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1],"name")}"
  cidr_block          = "10.1.20.0/24"
  display_name        = "APACPursuit_Public_Subnet"
  dns_label           = "Public"

  security_list_ids = ["${oci_core_virtual_network.APACPursuitVCN.default_security_list_id}",
    "${oci_core_security_list.APACPursuitSecurityList_Public.id}",
  ]

  compartment_id  = "${var.compartment_ocid}"
  vcn_id          = "${oci_core_virtual_network.APACPursuitVCN.id}"
  route_table_id  = "${oci_core_route_table.APACPursuitRTforPublic.id}"
  dhcp_options_id = "${oci_core_virtual_network.APACPursuitVCN.default_dhcp_options_id}"
  #Default is false (public subnet)
  prohibit_public_ip_on_vnic = false
}


resource "oci_core_subnet" "APACPursuit_Private_Subnet" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1],"name")}"
  cidr_block          = "10.1.10.0/24"
  display_name        = "APACPursuit_Private_Subnet"
  dns_label           = "Private"

  security_list_ids = ["${oci_core_virtual_network.APACPursuitVCN.default_security_list_id}",
    "${oci_core_security_list.APACPursuitSecurityList_Private.id}",
  ]

  compartment_id  = "${var.compartment_ocid}"
  vcn_id          = "${oci_core_virtual_network.APACPursuitVCN.id}"
  route_table_id  = "${oci_core_route_table.APACPursuitRTforPrivate.id}"
  dhcp_options_id = "${oci_core_virtual_network.APACPursuitVCN.default_dhcp_options_id}"

  prohibit_public_ip_on_vnic = true
}


resource "oci_core_internet_gateway" "APACPursuitIG" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "APACPursuitGateway"
  vcn_id         = "${oci_core_virtual_network.APACPursuitVCN.id}"
}


resource "oci_core_nat_gateway" "APACPursuitNAT" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "APACPursuitNATGateway"
  vcn_id         = "${oci_core_virtual_network.APACPursuitVCN.id}"
}

resource "oci_core_route_table" "APACPursuitRTforPublic" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.APACPursuitVCN.id}"
  display_name   = "APACPursuitRouteTable"

  route_rules {
    destination        = "0.0.0.0/0"
    network_entity_id = "${oci_core_internet_gateway.APACPursuitIG.id}"
  }
}

resource "oci_core_route_table" "APACPursuitRTforPrivate" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.APACPursuitVCN.id}"
  display_name   = "APACPursuitRTforPrivate"

  route_rules {
    destination        = "0.0.0.0/0"
    network_entity_id = "${oci_core_nat_gateway.APACPursuitNAT.id}"
  }
}

resource "oci_core_security_list" "APACPursuitSecurityList_Public" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.APACPursuitVCN.id}"
  display_name   = "APACPursuitSecurityList_Public"

  # ICMP Rules
  ingress_security_rules {
    protocol  = 1
    source    = "0.0.0.0/0"
    stateless = true

    icmp_options {
      type = 3
      code = 4
    }
  }

  // Port 9000 for Docker-Portainer, Registry, RegistryUI
  ingress_security_rules {
    protocol  = "6"         // tcp
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      // These values correspond to the destination port range.
      min = 5000
      max = 5002
    }
  }

  // Port 8080 for APACPursuit
  ingress_security_rules {
    protocol  = "6"         // tcp
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      // These values correspond to the destination port range.
      min = 8080
      max = 8080
    }
  }

  // Port 8888 for APACPursuit
  ingress_security_rules {
    protocol  = "6"         // tcp
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      // These values correspond to the destination port range.
      min = 8888
      max = 8888
    }
  }

  // Port 22 for SSH from Bastion
  ingress_security_rules {
    protocol  = "6"         // tcp
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      // These values correspond to the destination port range.
      min = 22
      max = 22
    }
  }

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"         // tcp
  }
}



resource "oci_core_security_list" "APACPursuitSecurityList_Private" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.APACPursuitVCN.id}"
  display_name   = "APACPursuitSecurityList_Private"

  # ICMP Rules
  ingress_security_rules {
    protocol  = 1
    source    = "10.1.20.0/24"
    stateless = true

    icmp_options {
      type = 3
      code = 4
    }
  }
  // Port 22 for SSH from Bastion
  ingress_security_rules {
    protocol  = "6"         // tcp
    source    = "10.1.20.0/24"
    stateless = false

    tcp_options {
      // These values correspond to the destination port range.
      min = 22
      max = 22
    }
  }

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"         // tcp
  }
}
