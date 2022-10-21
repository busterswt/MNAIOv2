# Security Group
resource "openstack_networking_secgroup_v2" "secgrp_ovn_lab" {
  name        = "secgrp_ovn_lab"
  description = "Open ALL tcp"
}

# Security Group Rules

resource "openstack_networking_secgroup_rule_v2" "all_tcp" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  remote_ip_prefix = "0.0.0.0/0"
  port_range_min = 1
  port_range_max = 65535
  security_group_id = "${openstack_networking_secgroup_v2.secgrp_ovn_lab.id}"
}

resource "openstack_networking_secgroup_rule_v2" "all_udp" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "udp"
  remote_ip_prefix = "0.0.0.0/0"
  port_range_min = 1
  port_range_max = 65535
  security_group_id = "${openstack_networking_secgroup_v2.secgrp_ovn_lab.id}"
}

resource "openstack_networking_secgroup_rule_v2" "all_icmp" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "icmp"
  remote_ip_prefix = "0.0.0.0/0"
  port_range_min = 1
  port_range_max = 65535
  security_group_id = "${openstack_networking_secgroup_v2.secgrp_ovn_lab.id}"
}
