#### COMPUTES  ####

# Create instance
#
resource "openstack_compute_instance_v2" "compute" {
  for_each    = var.compute_instance_names
  name        = each.key
  image_name  = var.image
  flavor_name = var.flavor_compute
  key_pair    = openstack_compute_keypair_v2.user_key.name
  user_data   = file("scripts/first-boot.sh")
  network {
    port = openstack_networking_port_v2.compute-mgmt[each.key].id
  }
  network {
    port = openstack_networking_port_v2.compute-overlay[each.key].id
  }
}

# Create network port
resource "openstack_networking_port_v2" "compute-mgmt" {
  for_each       = var.compute_instance_names
  name           = "port-compute-${each.key}"
  network_id     = openstack_networking_network_v2.ovn-management.id
  admin_state_up = true
  security_group_ids = [
    openstack_networking_secgroup_v2.secgrp_ovn_lab.id
  ]
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.ovn-management.id
  }
}

resource "openstack_networking_port_v2" "compute-overlay" {
  for_each       = var.compute_instance_names
  name           = "port-compute-${each.key}"
  network_id     = openstack_networking_network_v2.ovn-overlay.id
  admin_state_up = true
  security_group_ids = [
    openstack_networking_secgroup_v2.secgrp_ovn_lab.id
  ]
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.ovn-overlay.id
  }
}
