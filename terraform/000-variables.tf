# Params file for variables

#### GLANCE ####
# Update the string to an image in your environment
variable "image" {
  type    = string
  description = "The short name  of the Glance image to use for the server."
}

#### NEUTRON ####
variable "external_network" {
  type    = map(string)
  description = "The NAME and UUID of an External Provider Network for Floating IPs (dict)."
}

#### CINDER ####
variable "osd_volume_size" {
  type    = number
  description = "Default volume size for Ceph OSDs"
  default = 10
}

#######################################
#### DO NOT CHANGE BELOW THIS LINE ####
#######################################

variable "dns_ip" {
  type    = list(string)
  default = ["1.1.1.1", "1.0.0.1"]
}

variable "internal_lb_vip_address" {
  type    = string
  default = "172.29.236.10"
}

variable "external_lb_vip_address" {
  type    = string
  default = "172.29.236.11"
}

variable "network_management" {
  type = map(string)
  default = {
    subnet_name = "subnet-mnaio-management"
    cidr        = "10.240.0.0/22"
  }
}

variable "network_container" {
  type = map(string)
  default = {
    subnet_name = "subnet-mnaio-container"
    cidr        = "172.29.236.0/22"
  }
}

variable "network_overlay" {
  type = map(string)
  default = {
    subnet_name = "subnet-mnaio-overlay"
    cidr        = "172.29.240.0/22"
  }
}

variable "network_storage" {
  type = map(string)
  default = {
    subnet_name = "subnet-mnaio-storage"
    cidr        = "172.29.244.0/22"
  }
}

variable "network_replication" {
  type = map(string)
  default = {
    subnet_name = "subnet-mnaio-replication"
    cidr        = "172.29.252.0/22"
  }
}

variable "network_provider" {
  type = map(string)
  default = {
    subnet_name = "subnet-mnaio-provider"
    cidr        = "10.239.0.0/22"
  }
}

variable "management_router" {
  type = map(string)
  default = {
    name        = "mnaio-mgmt-router"
  }
}

variable "overcloud_router" {
  type = map(string)
  default = {
    name        = "mnaio-overcloud-router"
  }
}

#### VM controller parameters ####

# The provider addr is a dummy block that will not be used.

# For controllers, ens3 is br-mgmt, ens4 is br-overlay, ens5 is br-storage, and ens6 is provider bridge interface
locals {
 controller_nodes = {
    mnaio-controller1 = { mgmt_addr = "10.240.0.21", container_addr = "172.29.236.21", overlay_addr = "172.29.240.21",
                          storage_addr = "172.29.244.21", provider_addr = "10.239.3.21" },
    mnaio-controller2 = { mgmt_addr = "10.240.0.22", container_addr = "172.29.236.22", overlay_addr = "172.29.240.22",
                          storage_addr = "172.29.244.22", provider_addr = "10.239.3.22" },
    mnaio-controller3 = { mgmt_addr = "10.240.0.23", container_addr = "172.29.236.23", overlay_addr = "172.29.240.23",
                          storage_addr = "172.29.244.23", provider_addr = "10.239.3.23" }
  }
}

#### VM compute parameters ####

# For computes, ens3 is br-mgmt, ens4 is br-overlay, ens5 is br-storage, and ens6 is provider bridge interface
locals {
  compute_nodes = {
    mnaio-compute1 = { mgmt_addr = "10.240.0.31", container_addr = "172.29.236.31", overlay_addr = "172.29.240.31",
                       storage_addr = "172.29.244.31", provider_addr = "10.239.3.31" },
    mnaio-compute2 = { mgmt_addr = "10.240.0.32", container_addr = "172.29.236.32", overlay_addr = "172.29.240.32",
                       storage_addr = "172.29.244.32", provider_addr = "10.239.3.32" },
    mnaio-compute3 = { mgmt_addr = "10.240.0.33", container_addr = "172.29.236.33", overlay_addr = "172.29.240.33",
                       storage_addr = "172.29.244.33", provider_addr = "10.239.3.33" }
  }
}

#### VM loadbalancer ####

# For load balancers, ens3 is br-mgmt
locals {
  loadbalancer_nodes = {
    mnaio-loadbalancer1 = { mgmt_addr = "10.240.0.41", container_addr = "172.29.236.41" },
    mnaio-loadbalancer2 = { mgmt_addr = "10.240.0.42", container_addr = "172.29.236.42" }
  }
}

#### VM Deployer ####

locals {
  deployer_nodes = {
    mnaio-deploy1 = { mgmt_addr = "10.240.0.51", container_addr = "172.29.236.51" }
  }
}

#### VM ceph ####

# For ceph nodes, ens3 is br-mgmt, ens4 is br-storage, ens5 is br-repl
locals {
  ceph_nodes = {
    mnaio-ceph1 = { mgmt_addr = "10.240.0.61", container_addr = "172.29.236.61", storage_addr = "172.29.244.61", replication_addr = "172.29.252.61" },
    mnaio-ceph2 = { mgmt_addr = "10.240.0.62", container_addr = "172.29.236.62", storage_addr = "172.29.244.62", replication_addr = "172.29.252.62" },
    mnaio-ceph3 = { mgmt_addr = "10.240.0.63", container_addr = "172.29.236.63", storage_addr = "172.29.244.63", replication_addr = "172.29.252.63" }
  }
}

#### Resources ####

resource "random_pet" "pet_name" {
  length = 2
}
