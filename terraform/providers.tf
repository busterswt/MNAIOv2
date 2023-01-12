# Copyright 2022, Rackspace US, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in witing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# 'OpenStack' provider documentation can be found at:
# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs
#

terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.48.0"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

# The OpenStack provider is using clouds.yaml.

provider "openstack" {
  cloud = "openstack"
}
