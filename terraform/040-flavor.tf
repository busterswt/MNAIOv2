#### Flavors ####

resource "openstack_compute_flavor_v2" "osa-mnaio-controller-flavor" {
  name  = "osa-mnaio-controller"
  ram   = "32768"
  vcpus = "12"
  disk  = "60"
}

resource "openstack_compute_flavor_v2" "osa-mnaio-compute-flavor" {
  name  = "osa-mnaio-compute"
  ram   = "16384"
  vcpus = "8"
  disk  = "40"
}

resource "openstack_compute_flavor_v2" "osa-mnaio-loadbalancer-flavor" {
  name  = "osa-mnaio-loadbalancer"
  ram   = "4096"
  vcpus = "4"
  disk  = "20"
}

resource "openstack_compute_flavor_v2" "osa-mnaio-deployer-flavor" {
  name  = "osa-mnaio-deployer"
  ram   = "4096"
  vcpus = "4"
  disk  = "20"
}
