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

set -u

source ansible-env.rc

# Destroy the Terraform environment
pushd terraform
  TF_VAR_image=dummy \
  TF_VAR_external_network='{"name":"dummy","uuid":"dummy"}' \
  terraform destroy -state=${MNAIO_TF_STATE_FILE}
popd

###############
#### CLEAN ####
###############

# This playbook cleans the local environment and deletes auto-generated Terraform files
ansible-playbook playbooks/clean.yml
