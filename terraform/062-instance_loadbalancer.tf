#### LOADBALANCERS ####

# Create instance
resource "openstack_compute_instance_v2" "loadbalancer" {
  for_each    = local.loadbalancer_nodes
  name        = "${join("-",["${random_pet.pet_name.id}","${each.key}"])}"
  image_name  = var.image
  flavor_id   = openstack_compute_flavor_v2.osa-mnaio-loadbalancer-flavor.id
  key_pair    = openstack_compute_keypair_v2.user_key.name
  user_data   = file("scripts/cloud-init.yaml")
  config_drive = true
  network {
    port = openstack_networking_port_v2.loadbalancer-mgmt[each.key].id
  }

  depends_on = [ openstack_images_image_v2.osa-mnaio-image ]
}

# Create network port
resource "openstack_networking_port_v2" "loadbalancer-mgmt" {
  for_each       = local.loadbalancer_nodes
  name           = "${join("-",["${random_pet.pet_name.id}","lb","${each.key}"])}"
  network_id     = openstack_networking_network_v2.mnaio-management.id
  admin_state_up = true
  no_security_groups = true
  port_security_enabled = false
  fixed_ip {
    ip_address = each.value.mgmt_addr
    subnet_id = openstack_networking_subnet_v2.mnaio-management.id
  }
}

#### Floating IPs ####

resource "openstack_networking_floatingip_v2" "loadbalancer_floating_ip_mgmt" {
  pool         = var.external_network["name"]
  for_each     = local.loadbalancer_nodes
}

resource "openstack_compute_floatingip_associate_v2" "loadbalancer_fip_associate_mgmt" {
  for_each        = local.loadbalancer_nodes
  instance_id     = openstack_compute_instance_v2.loadbalancer[each.key].id
  floating_ip     = "${openstack_networking_floatingip_v2.loadbalancer_floating_ip_mgmt[each.key].address}"
  fixed_ip        = "${openstack_compute_instance_v2.loadbalancer[each.key].network.0.fixed_ip_v4}"

  depends_on = [ openstack_networking_router_interface_v2.router_interface_mgmt ]
}
