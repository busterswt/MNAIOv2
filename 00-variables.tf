# Params file for variables

#### GLANCE
variable "image" {
  type    = string
  default = "Ubuntu Focal 20.04 LTS"
}

#### NEUTRON
#variable "external_network" {
#  type    = string
#  default = "external-network"
#}

# UUID of external gateway
#variable "external_gateway" {
#  type    = string
#  default = "f67f0d72-0ddf-11e4-9d95-e1f29f417e2f"
#}

variable "dns_ip" {
  type    = list(string)
  default = ["8.8.8.8", "8.8.8.4"]
}

variable "network_management" {
  type = map(string)
  default = {
    subnet_name = "subnet-ovn-management"
    cidr        = "172.25.1.0/24"
  }
}

variable "network_overlay" {
  type = map(string)
  default = {
    subnet_name = "subnet-ovn-overlay"
    cidr        = "172.25.2.0/24"
  }
}

#### VM controller parameters ####
variable "flavor_controller" {
  type    = string
  default = "osa-dev-8-8-60"
}


variable "controller_instance_names" {
  type = set(string)
  default = ["ovn-controller1",
             "ovn-controller2",
             "ovn-controller3"]
}

#### VM compute parameters ####
variable "flavor_compute" {
  type    = string
  default = "osa-dev-8-8-60"
}

variable "compute_instance_names" {
  type = set(string)
  default = ["ovn-compute1",
             "ovn-compute2",
             "ovn-compute3"]
}
