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
  description = "The NAME and UUID of an External Provider Network for Floating IPs."
}

#######################################
#### DO NOT CHANGE BELOW THIS LINE ####
#######################################

variable "dns_ip" {
  type    = list(string)
  default = ["8.8.8.8", "8.8.8.4"]
}

variable "internal_lb_vip_address" {
  type    = string
  default = "172.25.1.10"
}

variable "external_lb_vip_address" {
  type    = string
  default = "172.25.1.11"
}

variable "network_management" {
  type = map(string)
  default = {
    subnet_name = "subnet-mnaio-management"
    cidr        = "172.25.1.0/24"
  }
}

variable "network_overlay" {
  type = map(string)
  default = {
    subnet_name = "subnet-mnaio-overlay"
    cidr        = "172.25.2.0/24"
  }
}

variable "network_provider" {
  type = map(string)
  default = {
    subnet_name = "subnet-mnaio-provider"
    cidr        = "172.25.3.0/24"
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

# The provider IP is a dummy block that will not be used.

locals {
 controller_nodes = {
    mnaio-controller1 = { mgmt_addr = "172.25.1.21", mgmt_mac = "fa:16:3d:b8:e8:01", overlay_addr = "172.25.2.21", overlay_mac = "fa:16:3d:b8:e9:01",
                          provider_addr = "172.25.3.21", provider_mac = "fa:16:3d:b8:e5:01" },
    mnaio-controller2 = { mgmt_addr = "172.25.1.22", mgmt_mac = "fa:16:3d:b8:e8:03",
                          overlay_addr = "172.25.2.22", overlay_mac = "fa:16:3d:b8:e9:04",
                          provider_addr = "172.25.3.22", provider_mac = "fa:16:3d:b8:e5:02" },
    mnaio-controller3 = { mgmt_addr = "172.25.1.23", mgmt_mac = "fa:16:3d:b8:e8:05", overlay_addr = "172.25.2.23", overlay_mac = "fa:16:3d:b8:e9:06",
                          provider_addr = "172.25.3.23", provider_mac = "fa:16:3d:b8:e5:03" }
  }
}

#### VM compute parameters ####

locals {
  compute_nodes = {
    mnaio-compute1 = { mgmt_addr = "172.25.1.31", mgmt_mac = "fa:16:3d:b8:e7:01", overlay_addr = "172.25.2.31", overlay_mac = "fa:16:3d:b8:e6:02", provider_mac = "fa:16:3d:b8:e5:04",
                       provider_addr = "172.25.3.31", provider_mac = "fa:16:3d:b8:e5:04" },
    mnaio-compute2 = { mgmt_addr = "172.25.1.32", mgmt_mac = "fa:16:3d:b8:e7:03", overlay_addr = "172.25.2.32", overlay_mac = "fa:16:3d:b8:e6:04", provider_mac = "fa:16:3d:b8:e5:05",
                       provider_addr = "172.25.3.32", provider_mac = "fa:16:3d:b8:e5:05" },
    mnaio-compute3 = { mgmt_addr = "172.25.1.33", mgmt_mac = "fa:16:3d:b8:e7:05", overlay_addr = "172.25.2.33", overlay_mac = "fa:16:3d:b8:e6:06", provider_mac = "fa:16:3d:b8:e5:06",
                       provider_addr = "172.25.3.33", provider_mac = "fa:16:3d:b8:e5:06" }
  }
}

#### VM loadbalancer ####

locals {
  loadbalancer_nodes = {
    mnaio-loadbalancer1 = { mgmt_addr = "172.25.1.41" },
    mnaio-loadbalancer2 = { mgmt_addr = "172.25.1.42" }
  }
}

#### VM Deployer ####

locals {
  deployer_nodes = {
    mnaio-deploy1 = { mgmt_addr = "172.25.1.51" }
  }
}
