resource "oci_core_virtual_network" "hitcountVCN" {
  cidr_block     = "10.5.0.0/16"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "hitcountVCN"
  dns_label      = "hitcountvcn"
}

resource "oci_core_subnet" "publicSubnet" {
  cidr_block          = "10.5.0.0/24"
  display_name        = "publicSubnet"
  dns_label           = "publicsubnet"
  security_list_ids   = ["${oci_core_virtual_network.hitcountVCN.default_security_list_id}","${oci_core_security_list.lbSecurityList.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.hitcountVCN.id}"
  route_table_id      = "${oci_core_route_table.publicRT.id}"
  dhcp_options_id     = "${oci_core_virtual_network.hitcountVCN.default_dhcp_options_id}"
}

resource "oci_core_subnet" "appSubnet" {
  cidr_block          = "10.5.1.0/24"
  display_name        = "appSubnet"
  dns_label           = "appsubnet"
  security_list_ids   = ["${oci_core_virtual_network.hitcountVCN.default_security_list_id}","${oci_core_security_list.appSecurityList.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.hitcountVCN.id}"
  route_table_id      = "${oci_core_route_table.appdbRT.id}"
  dhcp_options_id     = "${oci_core_virtual_network.hitcountVCN.default_dhcp_options_id}"
  prohibit_public_ip_on_vnic  = true
}

resource "oci_core_subnet" "dbSubnet" {
  cidr_block          = "10.5.2.0/24"
  display_name        = "dbSubnet"
  dns_label           = "dbsubnet"
  security_list_ids   = ["${oci_core_virtual_network.hitcountVCN.default_security_list_id}","${oci_core_security_list.dbSecurityList.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.hitcountVCN.id}"
  route_table_id      = "${oci_core_route_table.appdbRT.id}"
  dhcp_options_id     = "${oci_core_virtual_network.hitcountVCN.default_dhcp_options_id}"
  prohibit_public_ip_on_vnic  = true
}

resource "oci_core_internet_gateway" "hitcountIG" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "hitcountIG"
  vcn_id         = "${oci_core_virtual_network.hitcountVCN.id}"
}

resource "oci_core_nat_gateway" "hitcountNATgw" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "hitcountNATgw"
  vcn_id         = "${oci_core_virtual_network.hitcountVCN.id}"
}

resource "oci_core_route_table" "publicRT" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.hitcountVCN.id}"
  display_name   = "PublicSubnetRouteTable"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = "${oci_core_internet_gateway.hitcountIG.id}"
  }
}

resource "oci_core_route_table" "appdbRT" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.hitcountVCN.id}"
  display_name   = "appdbSubnetRouteTable"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = "${oci_core_nat_gateway.hitcountNATgw.id}"
  }
}

resource "oci_core_security_list" "lbSecurityList" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.hitcountVCN.id}"
  display_name   = "lbSecurityList"

  ingress_security_rules {
    protocol  = "6"         // tcp
    source    = "0.0.0.0/0"
    stateless = false
    tcp_options {
      "min" = 80
      "max" = 80
    }
  }

  egress_security_rules {
    protocol    = "6"
    destination = "10.5.1.0/24"
    stateless   = false
    tcp_options {
      "min" = 8080
      "max" = 8080
    }
  }
}

resource "oci_core_security_list" "appSecurityList" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.hitcountVCN.id}"
  display_name   = "appSecurityList"

  ingress_security_rules {
    protocol  = "6"         // tcp
    source    = "10.5.0.0/24"
    stateless = false
    tcp_options {
      "min" = 8080
      "max" = 8080
    }
  }

  ingress_security_rules {
    protocol  = "6"         // tcp
    source    = "10.5.0.0/24"
    stateless = false
    tcp_options {
      "min" = 22
      "max" = 22
    }
  }

  ingress_security_rules {
    protocol  = "1"         // ICMP
    source    = "10.5.0.0/16"
    stateless = false
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    stateless   = false
  }
}

resource "oci_core_security_list" "dbSecurityList" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.hitcountVCN.id}"
  display_name   = "dbSecurityList"

  ingress_security_rules {
    protocol  = "6"         // tcp
    source    = "10.5.1.0/24"
    stateless = false
    tcp_options {
      "min" = 27017
      "max" = 27017
    }
  }

  ingress_security_rules {
    protocol  = "6"         // tcp
    source    = "10.5.0.0/24"
    stateless = false
    tcp_options {
      "min" = 22
      "max" = 22
    }
  }

  ingress_security_rules {
    protocol  = "1"         // ICMP
    source    = "10.5.0.0/16"
    stateless = false
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    stateless   = false
  }
}
