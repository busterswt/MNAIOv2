#!/usr/bin/env bash
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

if:IsSet() {
  [[ ${!1-x} == x ]] && return 1 || return 0
}

set -u

source ansible-env.rc

# Check for environment variables needed for Terraform
if:IsSet OS_PASSWORD || echo "Please set OS_PASSWORD or source the OpenStack openrc file."
if:IsSet OS_USERNAME || echo "Please set OS_USERNAME or source the OpenStack openrc file."
if:IsSet OS_PROJECT_NAME || echo "Please set OS_PROJECT_NAME or source the OpenStack openrc file."
if:IsSet OS_AUTH_URL || echo "Please set OS_AUTH_URL or source the OpenStack openrc file."
if:IsSet MNAIO_OSA_EXTERNAL_NETWORK_NAME || echo "Please set MNAIO_OSA_EXTERNAL_NETWORK_NAME."
if:IsSet MNAIO_OSA_EXTERNAL_NETWORK_UUID ||  echo "Please set MNAIO_OSA_EXTERNAL_NETWORK_UUID."

# DO NOT MODIFY #
export TF_VAR_image=${MNAIO_OSA_VM_IMAGE:-"focal"}

###################
#### THE GOODS ####
###################

#pushd terraform
#terraform init
#popd

# This playbook downloads images to the local machine for later uploading to Glance
ansible-playbook playbooks/download-images.yml \
   -e osa_vm_image=${MNAIO_OSA_VM_IMAGE:-"focal"}

# This playbook deploys VMs onto an existing OpenStack cloud using Terraform
# We run it twice due to missing inventory the first time
ansible-playbook playbooks/deploy-vms.yml
ansible-playbook -i playbooks/inventory/hosts playbooks/deploy-vms.yml

# This playbook bootstraps the VMs (networking, keys, etc)
ansible-playbook -i playbooks/inventory/hosts playbooks/bootstrap-vms.yml

# This playbook bootstraps OpenStack-Ansible onto deployed VMs
ansible-playbook -i playbooks/inventory/hosts playbooks/deploy-osa.yml \
   -e osa_neutron_plugin=${MNAIO_OSA_NEUTRON_PLUGIN:-"ml2.ovs"} \
   -e osa_branch=${MNAIO_OSA_BRANCH:-"master"}
