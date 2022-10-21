resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.tmpl",
    {
      controller_nodes = openstack_networking_floatingip_v2.controller_floating_ip_mgmt
      compute_nodes = openstack_networking_floatingip_v2.compute_floating_ip_mgmt
      loadbalancer_nodes = openstack_networking_floatingip_v2.loadbalancer_floating_ip_mgmt
      deployer_nodes = openstack_networking_floatingip_v2.deployer_floating_ip_mgmt
      keypath = abspath("${path.module}/../id_rsa_mnaio.key")
    }
  )
  filename = "${path.module}/../playbooks/inventory/hosts"
  
  depends_on = [ openstack_networking_floatingip_v2.controller_floating_ip_mgmt,
                 openstack_networking_floatingip_v2.compute_floating_ip_mgmt,
                 openstack_networking_floatingip_v2.loadbalancer_floating_ip_mgmt,
                 openstack_networking_floatingip_v2.deployer_floating_ip_mgmt ]
}
