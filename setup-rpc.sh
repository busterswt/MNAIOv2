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

###################
#### THE GOODS ####
###################

if [ "$MNAIO_DEPLOY" == "rpc" ]; then
    # This playbook sets up Rackspace Private Cloud (OSA) onto deployed VMs
    ansible-playbook -i playbooks/inventory/hosts playbooks/setup-rpc.yml \
      -e osa_neutron_plugin=${MNAIO_OSA_NEUTRON_PLUGIN:-"ml2.ovs"} \
      -e osa_branch=${MNAIO_OSA_BRANCH:-"master"} \
      -e osa_no_containers=${MNAIO_OSA_NO_CONTAINERS:-"true"}
else
    echo "ERROR: This script requires an RPC deployment"
    exit 1
fi
