resource "oci_load_balancer_load_balancer" "hitcountLB" {
    compartment_id = "${var.compartment_ocid}"
    display_name = "hitcountLB"
    shape = "100Mbps"
    subnet_ids = ["${oci_core_subnet.publicSubnet.id}"]
    is_private = false
}

resource "oci_load_balancer_listener" "hitcountListener" {
    default_backend_set_name = "${oci_load_balancer_backend_set.appservers.name}"
    load_balancer_id = "${oci_load_balancer_load_balancer.hitcountLB.id}"
    name = "hitcountListener"
    port = "80"
    protocol = "HTTP"
}

resource "oci_load_balancer_backend_set" "appservers" {
  name             = "appservers"
  load_balancer_id = "${oci_load_balancer_load_balancer.hitcountLB.id}"
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "8080"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/"
  }
}

resource "oci_load_balancer_backend" "appserver0" {
  depends_on = ["oci_core_instance.appserver"]
  load_balancer_id = "${oci_load_balancer_load_balancer.hitcountLB.id}"
  backendset_name  = "${oci_load_balancer_backend_set.appservers.name}"
  ip_address       = "${oci_core_instance.appserver.0.private_ip}"
  port             = 8080
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

resource "oci_load_balancer_backend" "appserver1" {
  depends_on = ["oci_core_instance.appserver"]
  load_balancer_id = "${oci_load_balancer_load_balancer.hitcountLB.id}"
  backendset_name  = "${oci_load_balancer_backend_set.appservers.name}"
  ip_address       = "${oci_core_instance.appserver.1.private_ip}"
  port             = 8080
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}
