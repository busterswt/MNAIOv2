#### NETWORK CONFIGURATION ####

# This router will connect all MNAIO-related networks
# Connectivity to the management interfaces will be provided
# via Floating IPs. Same for deployed VMs (at some point).

resource "openstack_networking_router_v2" "mnaio-mgmt-router" {
  name                = "${join("-",["${random_pet.pet_name.id}","${var.management_router.name}"])}"
  admin_state_up      = true
  external_network_id = var.external_network["uuid"]
  enable_snat         = true
}

# This router will act as a gateway for the 'external' network deployed in the
# overcloud, which for the purpose of MNAIO is for  VMs deployed
# and accessed once the cloud is deployed.

resource "openstack_networking_router_v2" "mnaio-overcloud-router" {
  name                = "${join("-",["${random_pet.pet_name.id}","${var.overcloud_router.name}"])}"
  admin_state_up      = true
  external_network_id = var.external_network["uuid"]
  enable_snat         = true
}

#### MNAIO MANGEMENT NETWORK ####

# This is a "vlan" network in the underlay, and needs
# to be terminated on the Firepower.

resource "openstack_networking_network_v2" "mnaio-management" {
  name = "${join("-",["${random_pet.pet_name.id}","mnaio-management"])}"
}

resource "openstack_networking_subnet_v2" "mnaio-management" {
  name            = "${join("-",["${random_pet.pet_name.id}","${var.network_management["subnet_name"]}"])}"
  network_id      = openstack_networking_network_v2.mnaio-management.id
  cidr            = var.network_management["cidr"]
  dns_nameservers = var.dns_ip
}

# Create a router and attacn to the MNAIO management network

resource "openstack_networking_router_interface_v2" "router_interface_mgmt" {
  router_id = "${openstack_networking_router_v2.mnaio-mgmt-router.id}"
  subnet_id = "${openstack_networking_subnet_v2.mnaio-management.id}"
}

#### MNAIO OVERLAY NETWORK ####


resource "openstack_networking_network_v2" "mnaio-overlay" {
  name = "mnaio-overlay"
}

#### MNAIO OVERLAY SUBNET ####

resource "openstack_networking_subnet_v2" "mnaio-overlay" {
  name            = var.network_overlay["subnet_name"]
  network_id      = openstack_networking_network_v2.mnaio-overlay.id
  cidr            = var.network_overlay["cidr"]
  dns_nameservers = var.dns_ip
  no_gateway      = true
}

#### MNAIO PROVIDER NETWORK ####

# The undercloud needs to provision a VLAN provider network
# that will be used by the overcloud as a FLAT provider network.
# This avoids the use of the 'trunk' plugin.

resource "openstack_networking_network_v2" "mnaio-provider-ext" {
  name = "mnaio-provider-ext"
  external = true
}

resource "openstack_networking_subnet_v2" "mnaio-provider-ext" {
  name            = var.network_provider["subnet_name"]
  network_id      = openstack_networking_network_v2.mnaio-provider-ext.id
  cidr            = var.network_provider["cidr"]
  no_gateway      = true
}

#resource "openstack_networking_router_interface_v2" "router_interface_overcloud_ext" {
#  router_id = "${openstack_networking_router_v2.mnaio-overcloud-router.id}"
#  subnet_id = "${openstack_networking_subnet_v2.mnaio-provider-ext.id}"
#}

