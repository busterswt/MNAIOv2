
#### CONTROLLERS ####

# Create instance
resource "openstack_compute_instance_v2" "controller" {
  for_each    = local.controller_nodes
  name        = each.key
  image_name  = var.image
  flavor_id   = openstack_compute_flavor_v2.osa-mnaio-controller-flavor.id
  key_pair    = openstack_compute_keypair_v2.user_key.name
  user_data   = file("scripts/cloud-init.yaml")
  network {
    port = openstack_networking_port_v2.controller-mgmt[each.key].id
  }
  network {
    port = openstack_networking_port_v2.controller-overlay[each.key].id
  }
  network {
    port = openstack_networking_port_v2.controller-provider[each.key].id
  }

  depends_on = [ openstack_images_image_v2.osa-mnaio-image ]
}

# Create network port
resource "openstack_networking_port_v2" "controller-mgmt" {
  for_each       = local.controller_nodes
  name           = "port-controller-${each.key}"
  network_id     = openstack_networking_network_v2.mnaio-management.id
  admin_state_up = true
  no_security_groups = true
  port_security_enabled = false
  mac_address = each.value.mgmt_mac
  fixed_ip {
    ip_address = each.value.mgmt_addr
    subnet_id = openstack_networking_subnet_v2.mnaio-management.id
  }
}

resource "openstack_networking_port_v2" "controller-overlay" {
  for_each       = local.controller_nodes
  name           = "port-controller-${each.key}"
  network_id     = openstack_networking_network_v2.mnaio-overlay.id
  admin_state_up = true
  no_security_groups = true
  port_security_enabled = false
  mac_address = each.value.overlay_mac
  fixed_ip {
    ip_address = each.value.overlay_addr
    subnet_id = openstack_networking_subnet_v2.mnaio-overlay.id
  }
}

resource "openstack_networking_port_v2" "controller-provider" {
  for_each       = local.controller_nodes
  name           = "port-controller-${each.key}"
  network_id     = openstack_networking_network_v2.mnaio-provider-ext.id
  admin_state_up = true
  no_security_groups = true
  port_security_enabled = false
  mac_address = each.value.provider_mac
  fixed_ip {
    ip_address = each.value.provider_addr
    subnet_id = openstack_networking_subnet_v2.mnaio-provider-ext.id
  }
}

#### Floating IPs ####

resource "openstack_networking_floatingip_v2" "controller_floating_ip_mgmt" {
  pool         = var.external_network["name"]
  for_each     = local.controller_nodes
}

resource "openstack_compute_floatingip_associate_v2" "controller_fip_associate_mgmt" {
  for_each        = local.controller_nodes
  instance_id     = openstack_compute_instance_v2.controller[each.key].id
  floating_ip     = "${openstack_networking_floatingip_v2.controller_floating_ip_mgmt[each.key].address}"
  fixed_ip        = "${openstack_compute_instance_v2.controller[each.key].network.0.fixed_ip_v4}"
}
