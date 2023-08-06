#!/usr/bin/env bash
# Copyright 2023, Rackspace US, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

## Shell Opts ----------------------------------------------------------------
set -e -u -x

## Vars ----------------------------------------------------------------------
export HTTP_PROXY=${HTTP_PROXY:-""}
export HTTPS_PROXY=${HTTPS_PROXY:-""}
# The Ansible version used for testing
export ANSIBLE_PACKAGE=${ANSIBLE_PACKAGE:-"ansible-base==2.10.5"}
export ANSIBLE_ROLE_FILE=${ANSIBLE_ROLE_FILE:-"ansible-role-requirements.yml"}
export ANSIBLE_COLLECTION_FILE=${ANSIBLE_COLLECTION_FILE:-"ansible-collection-requirements.yml"}
export USER_ROLE_FILE=${USER_ROLE_FILE:-"user-role-requirements.yml"}
export USER_COLLECTION_FILE=${USER_COLLECTION_FILE:-"user-collection-requirements.yml"}
export SSH_DIR=${SSH_DIR:-"/root/.ssh"}
export DEBIAN_FRONTEND=${DEBIAN_FRONTEND:-"noninteractive"}

# Use pip opts to add options to the pip install command.
# This can be used to tell it which index to use, etc.
export PIP_OPTS=${PIP_OPTS:-""}

# This script should be executed from the root directory of the cloned repo
cd "$(dirname "${0}")/.."

## Functions -----------------------------------------------------------------
info_block "Checking for required libraries." 2> /dev/null ||
    source scripts/library.sh

# Create the ssh dir if needed
ssh_key_create

# Determine the distribution which the host is running on
determine_distro

# Install the base packages
case ${DISTRO_ID} in
    centos|rhel)
        VERS=${DISTRO_VERSION%%.*}
        dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-${VERS}.noarch.rpm && dnf update

        dnf -y install \
          git curl autoconf gcc gcc-c++ nc \
          python3 python3-devel libselinux-python3 \
          openssl-devel libffi-devel \
          python3-virtualenv rsync snapd


        systemctl enable --now snapd.socket
        if [ ! -e /snap ]; then
	  ln -s /var/lib/snapd/snap /snap
        fi

	snap install --classic terraform
        ;;
    ubuntu|debian)

        apt-get update
        DEBIAN_FRONTEND=noninteractive apt-get -y install \
          git-core curl gcc netcat \
          python3 python3-dev \
          libssl-dev libffi-dev \
          python3-apt virtualenv \
          python3-minimal snap

	snap install --classic terraform
        ;;
esac

# Ensure that our shell knows about the new virtualenv
hash -r virtualenv

# Ensure we use the HTTPS/HTTP proxy with pip if it is specified
if [ -n "$HTTPS_PROXY" ]; then
  PIP_OPTS+="--proxy $HTTPS_PROXY"

elif [ -n "$HTTP_PROXY" ]; then
  PIP_OPTS+="--proxy $HTTP_PROXY"
fi

PYTHON_EXEC_PATH="${PYTHON_EXEC_PATH:-$(which python3 || which python2 || which python)}"
PYTHON_VERSION="$($PYTHON_EXEC_PATH -c 'import sys; print(".".join(map(str, sys.version_info[:3])))')"

# Use https when Python with native SNI support is available
UPPER_CONSTRAINTS_PROTO=$([ "$PYTHON_VERSION" == $(echo -e "$PYTHON_VERSION\n2.7.9" | sort -V | tail -1) ] && echo "https" || echo "http")

# Set the location of the constraints to use for all pip installations
export UPPER_CONSTRAINTS_FILE=${UPPER_CONSTRAINTS_FILE:-"$UPPER_CONSTRAINTS_PROTO://opendev.org/openstack/requirements/raw/commit/485df374e5b52e1c7f3eed243b1518017f0c3f93/upper-constraints.txt"}


## Main ----------------------------------------------------------------------
info_block "Bootstrapping System with Ansible"

# Store the clone repo root location
export MNAIO_CLONE_DIR="$(pwd)"

if [[ -z "${SKIP_MNAIO_RUNTIME_VENV_BUILD+defined}" ]]; then
    build_ansible_runtime_venv
fi


# Update dependent roles
if [ -f "${ANSIBLE_COLLECTION_FILE}" ] && [[ -z "${SKIP_MNAIO_ROLE_CLONE+defined}" ]]; then
    #export ANSIBLE_LIBRARY="${MNAIO_CLONE_DIR}/playbooks/library"
    export ANSIBLE_LOOKUP_PLUGINS="/dev/null"
    export ANSIBLE_FILTER_PLUGINS="/dev/null"
    export ANSIBLE_ACTION_PLUGINS="/dev/null"
    export ANSIBLE_CALLBACK_PLUGINS="/dev/null"
    export ANSIBLE_CALLBACK_WHITELIST="/dev/null"
    export ANSIBLE_TEST_PLUGINS="/dev/null"
    export ANSIBLE_VARS_PLUGINS="/dev/null"
    export ANSIBLE_STRATEGY_PLUGINS="/dev/null"
    export ANSIBLE_CONFIG="none-ansible.cfg"
    export ANSIBLE_COLLECTIONS_PATH="/opt/ansible-mnaio2/"

    pushd scripts
      /opt/ansible-mnaio2/bin/ansible-playbook get-ansible-collection-requirements.yml \
        -e collection_file="${ANSIBLE_COLLECTION_FILE}" -e user_collection_file="${USER_COLLECTION_FILE}"

      #/opt/ansible-mnaio2/bin/ansible-playbook get-ansible-role-requirements.yml \
      #  -e role_file="${ANSIBLE_ROLE_FILE}" -e user_role_file="${USER_ROLE_FILE}"
    popd

    unset ANSIBLE_LIBRARY
    unset ANSIBLE_LOOKUP_PLUGINS
    unset ANSIBLE_FILTER_PLUGINS
    unset ANSIBLE_ACTION_PLUGINS
    unset ANSIBLE_CALLBACK_PLUGINS
    unset ANSIBLE_CALLBACK_WHITELIST
    unset ANSIBLE_TEST_PLUGINS
    unset ANSIBLE_VARS_PLUGINS
    unset ANSIBLE_STRATEGY_PLUGINS
    unset ANSIBLE_CONFIG
    unset ANSIBLE_COLLECTIONS_PATH
fi

echo "System is bootstrapped and ready for use."

