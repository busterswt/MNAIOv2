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

#set -u

source ansible-env.rc

# Terraform relies on the clouds.yaml for authentication.

if [ -z "$MNAIO_OSA_EXTERNAL_NETWORK_NAME" ]
then
    echo "Please set MNAIO_OSA_EXTERNAL_NETWORK_NAME"
    exit 1
fi

if [ -z "$MNAIO_OSA_EXTERNAL_NETWORK_UUID" ]
then
    echo "Please set MNAIO_OSA_EXTERNAL_NETWORK_UUID"
    exit 1
fi

# DO NOT MODIFY #
export TF_VAR_image=${MNAIO_OSA_VM_IMAGE:-"focal"}
export MNAIO_DEPLOY=${MNAIO_DEPLOY:-"osa"}
export MNAIO_OSA_VM_IMAGE_UUID=${MNAIO_OSA_VM_IMAGE_UUID:-""}

###################
#### THE GOODS ####
###################

pushd terraform
terraform init
popd

# This playbook downloads images to the local machine for later uploading to Glance
ansible-playbook playbooks/download-images.yml \
   -e osa_vm_image=${MNAIO_OSA_VM_IMAGE:-"focal"}

# This playbook generates Terraform files based on scenario
ansible-playbook playbooks/create-terraform.yml \
   -e osa_vm_image=${MNAIO_OSA_VM_IMAGE:-"focal"}

# This playbook deploys VMs onto an existing OpenStack cloud using Terraform
# We run it twice due to missing inventory the first time
ansible-playbook playbooks/deploy-vms.yml \
   -e osa_vm_image=${MNAIO_OSA_VM_IMAGE:-"focal"}
ansible-playbook -i playbooks/inventory/hosts playbooks/deploy-vms.yml \
   -e osa_vm_image=${MNAIO_OSA_VM_IMAGE:-"focal"}

# This playbook bootstraps the VMs (networking, keys, etc)
ansible-playbook -i playbooks/inventory/hosts playbooks/bootstrap-vms.yml

if [ "$MNAIO_DEPLOY" == "osa" ]; then
    # This playbook bootstraps OpenStack-Ansible onto deployed VMs
    ansible-playbook -i playbooks/inventory/hosts playbooks/deploy-osa.yml \
      -e osa_neutron_plugin=${MNAIO_OSA_NEUTRON_PLUGIN:-"ml2.ovs"} \
      -e osa_branch=${MNAIO_OSA_BRANCH:-"master"} \
      -e osa_no_containers=${MNAIO_OSA_NO_CONTAINERS:-"true"}
elif [ "$MNAIO_DEPLOY" == "rpc" ]; then
    # This playbook bootstraps Rackspace Private Cloud (OSA) onto deployed VMs
    ansible-playbook -i playbooks/inventory/hosts playbooks/pre-deploy-rpc.yml \
      -e osa_neutron_plugin=${MNAIO_OSA_NEUTRON_PLUGIN:-"ml2.ovs"} \
      -e osa_branch=${MNAIO_OSA_BRANCH:-"master"} \
      -e osa_no_containers=${MNAIO_OSA_NO_CONTAINERS:-"true"}
else
    echo "ERROR: Please set MNAIO_DEPLOY to 'osa' or 'rpc'"
    exit 1
fi
