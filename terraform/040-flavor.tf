#### Flavors ####

resource "openstack_compute_flavor_v2" "osa-mnaio-controller-flavor" {
  name  = "${join("-",["${random_pet.pet_name.id}","osa-mnaio-controller"])}"
  ram   = "32768"
  vcpus = "12"
  disk  = "60"
}

resource "openstack_compute_flavor_v2" "osa-mnaio-compute-flavor" {
  name  = "${join("-",["${random_pet.pet_name.id}","osa-mnaio-compute"])}"
  ram   = "16384"
  vcpus = "8"
  disk  = "40"
}

resource "openstack_compute_flavor_v2" "osa-mnaio-loadbalancer-flavor" {
  name  = "${join("-",["${random_pet.pet_name.id}","osa-mnaio-lb"])}"
  ram   = "4096"
  vcpus = "4"
  disk  = "20"
}

resource "openstack_compute_flavor_v2" "osa-mnaio-deployer-flavor" {
  name  = "${join("-",["${random_pet.pet_name.id}","osa-mnaio-deploy"])}"
  ram   = "4096"
  vcpus = "4"
  disk  = "20"
}

resource "openstack_compute_flavor_v2" "osa-mnaio-ceph-flavor" {
  name  = "${join("-",["${random_pet.pet_name.id}","osa-mnaio-ceph"])}"
  ram   = "8192"
  vcpus = "4"
  disk  = "40"
}
