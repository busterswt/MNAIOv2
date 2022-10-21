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

# Destroy the Terraform environment

pushd terraform
TF_VAR_image=dummy \
TF_VAR_external_network='{"name":"dummy","uuid":"dummy"}' \
terraform destroy
popd
