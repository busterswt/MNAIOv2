#### NETWORK CONFIGURATION ####

# This is a "vlan" network in the underlay, and needs
# to be terminated on the Firepower.

resource "openstack_networking_network_v2" "ovn-management" {
  name = "ovn-management"
}

# This is a "vlan" network in the underlay.

resource "openstack_networking_network_v2" "ovn-overlay" {
  name = "ovn-overlay"
}

# No provider networks need to be defined, as these will be
# managed by the "overcloud" and terminated on the Firepower.

#### OVN-MANGEMENT SUBNET ####

resource "openstack_networking_subnet_v2" "ovn-management" {
  name            = var.network_management["subnet_name"]
  network_id      = openstack_networking_network_v2.ovn-management.id
  cidr            = var.network_management["cidr"]
  dns_nameservers = var.dns_ip
}

#### OVN-OVERLAY SUBNET ####

resource "openstack_networking_subnet_v2" "ovn-overlay" {
  name            = var.network_overlay["subnet_name"]
  network_id      = openstack_networking_network_v2.ovn-overlay.id
  cidr            = var.network_overlay["cidr"]
  dns_nameservers = var.dns_ip
}


