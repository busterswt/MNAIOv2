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
    time = {
      source  = "hashicorp/time"
      version = "~> 0.8.0"
    }
  }
}

# The 'password' argument for the provider is ommitted in favor of OS_PASSWORD environment variable.
# The 'user_name' argument for the provider is ommitted in favor of OS_USERNAME environment variable.
# The 'tenant_name' argument for the provider is ommitted in favor of OS_TENANT_NAME or OS_PROJECT_NAME environment variables.
# The 'auth_url' argument for the provider is ommitted in favor of OS_AUTH_URL environment variable.

provider "openstack" {
}

