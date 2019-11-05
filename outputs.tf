# Output the private and public IPs of the instance

output "APACPursuit_Instance_PrivateIP" {
  value = ["${data.oci_core_vnic.APACPursuit_Instance_Vnic.private_ip_address}"]
}

output "Bastion_Vnic_PublicIP" {
  value = ["${data.oci_core_vnic.Bastion_Vnic.public_ip_address}"]
}

output "audit_events" {
  value = "${data.oci_audit_events.audit_events.audit_events}"
}