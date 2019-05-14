
resource "oci_core_instance" "bastion" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ads.availability_domains[0],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "bastion"
  shape               = "${var.instance_shape}"

  create_vnic_details {
    subnet_id        = "${oci_core_subnet.publicSubnet.id}"
    display_name     = "eth0"
    assign_public_ip = true
    hostname_label   = "bastion"
  }

  source_details {
    source_type = "image"
    source_id   = "${var.instance_image_ocid[var.region]}"
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data           = "${base64encode(file(var.bastionBootstrap))}"
  }
/*
  provisioner "file" {
    content     = "${var.ssh_private_key}"
    destination = "/home/opc/.ssh/id_rsa"
    connection {
      type     = "ssh"
      user     = "opc"
      private_key = "${var.ssh_private_key}"
    }
  } */

}

resource "oci_core_instance" "appserver" {
  count               = "${var.NumAppServer}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.ads.availability_domains[(count.index+1)%3],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "appserver${count.index}"
  shape               = "${var.instance_shape}"

  create_vnic_details {
    subnet_id        = "${oci_core_subnet.appSubnet.id}"
    display_name     = "eth0"
    assign_public_ip = false
    hostname_label   = "appserver${count.index}"
  }

  source_details {
    source_type = "image"
    source_id   = "${var.instance_image_ocid[var.region]}"
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data           = "${base64encode(file(var.appBootstrap))}"
  }
}

resource "oci_core_instance" "db" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ads.availability_domains[2],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "db"
  shape               = "${var.instance_shape}"

  create_vnic_details {
    subnet_id        = "${oci_core_subnet.dbSubnet.id}"
    display_name     = "eth0"
    assign_public_ip = false
    hostname_label   = "db"
  }

  source_details {
    source_type = "image"
    source_id   = "${var.instance_image_ocid[var.region]}"
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data           = "${base64encode(file(var.dbBootstrap))}"
  }
}
