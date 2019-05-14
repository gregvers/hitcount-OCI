# Output the private and public IPs of the instance
output "appServersPrivateIPs" {
  value = ["${oci_core_instance.appserver.*.private_ip}"]
}

output "dbPrivateIPs" {
  value = ["${oci_core_instance.db.private_ip}"]
}

output "bastionPublicIP" {
  value = ["${oci_core_instance.bastion.public_ip}"]
}

output "lb_public_ip" {
  value = ["${oci_load_balancer_load_balancer.hitcountLB.ip_addresses}"]
}
