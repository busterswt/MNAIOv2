# Security Group
resource "openstack_networking_secgroup_v2" "secgrp-mnaio" {
  name        = "${join("-",["${random_pet.pet_name.id}","secgrp-mnaio"])}"
  description = "Open ALL tcp"
}

# Security Group Rules

resource "openstack_networking_secgroup_rule_v2" "all_tcp" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgrp-mnaio.id}"
}

resource "openstack_networking_secgroup_rule_v2" "all_udp" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "udp"
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgrp-mnaio.id}"
}

resource "openstack_networking_secgroup_rule_v2" "all_icmp" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "icmp"
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgrp-mnaio.id}"
}
