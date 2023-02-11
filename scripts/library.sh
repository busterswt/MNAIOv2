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


## Vars ----------------------------------------------------------------------
LINE='----------------------------------------------------------------------'
ANSIBLE_PARAMETERS=${ANSIBLE_PARAMETERS:-""}
STARTTIME="${STARTTIME:-$(date +%s)}"
COMMAND_LOGS=${COMMAND_LOGS:-"/var/log/ansible_cmd_logs"}

# The vars used to prepare the Ansible runtime venv
PIP_COMMAND="/opt/ansible-mnaio2/bin/pip"


# The default SSHD configuration has MaxSessions = 10. If a deployer changes
#  their SSHD config, then the ANSIBLE_FORKS may be set to a higher number. We
#  set the value to 10 or the number of CPU's, whichever is less. This is to
#  balance between performance gains from the higher number, and CPU
#  consumption. If ANSIBLE_FORKS is already set to a value, then we leave it
#  alone.
#  ref: https://bugs.launchpad.net/openstack-ansible/+bug/1479812
if [ -z "${ANSIBLE_FORKS:-}" ]; then
  CPU_NUM=$(grep -c ^processor /proc/cpuinfo)
  if [ ${CPU_NUM} -lt "10" ]; then
    ANSIBLE_FORKS=${CPU_NUM}
  else
    ANSIBLE_FORKS=10
  fi
fi



## Functions -----------------------------------------------------------------
# Build ansible-runtime venv
function build_ansible_runtime_venv {
    # All distros have a python-virtualenv > 13.
    # - Centos 8 has 15.1, which holds pip 9.0.1, setuptools 28.8, wheel 0.29
    #   See also: http://mirror.centos.org/centos/7/os/x86_64/Packages/
    # - openSUSE 42.3 has 13.1.2, which holds pip 7.1.2, setuptools 18.2, wheel 0.24.
    #   See also: https://build.opensuse.org/package/show/openSUSE%3ALeap%3A42.3/python-virtualenv
    # - Ubuntu Xenial has 15.0.1, holding pip 8.1.1, setuptools 20.3, wheel 0.29
    #   See also: https://packages.ubuntu.com/xenial/python-virtualenv

    virtualenv --python=${PYTHON_EXEC_PATH} --never-download --clear /opt/ansible-mnaio2

    # The vars used to prepare the Ansible runtime venv
    PIP_OPTS+=" --constraint global-requirement-pins.txt"
    PIP_OPTS+=" --constraint ${UPPER_CONSTRAINTS_FILE}"

    # When executing the installation, we want to specify all our options on the CLI,
    # making sure to completely ignore any config already on the host. This is to
    # prevent the repo server's extra constraints being applied, which include
    # a different version of Ansible to the one we want to install. As such, we
    # use --isolated so that the config file is ignored.

    # Upgrade pip setuptools and wheel to the appropriate version
    ${PIP_COMMAND} install --isolated ${PIP_OPTS} --upgrade pip setuptools wheel

    # Install ansible and the other required packages
    ${PIP_COMMAND} install --isolated ${PIP_OPTS} -r requirements.txt ${ANSIBLE_PACKAGE}

    # Install python libraries when present
    #$PIP_COMMAND install -e .

    # Add SELinux support to the venv
    if [ -d "/usr/lib64/python3.6/site-packages/selinux/" ]; then
      rsync -avX /usr/lib64/python3.6/site-packages/selinux/ /opt/ansible-runtime/lib64/python3.6/site-packages/selinux/
      rsync -avX /usr/lib64/python3.6/site-packages/_selinux.cpython-36m-x86_64-linux-gnu.so /opt/ansible-runtime/lib64/python3.6/site-packages/
    fi
}


# Determine the distribution we are running on, so that we can configure it
# appropriately.
function determine_distro {
    source /etc/os-release 2>/dev/null
    export DISTRO_ID="${ID}"
    export DISTRO_VERSION="${VERSION_ID}"
    export DISTRO_NAME="${NAME}"
}

function ssh_key_create {
  # Ensure that the ssh key exists and is an authorized_key
  key_path="${HOME}/.ssh"
  key_file="${key_path}/id_rsa"

  # Ensure that the .ssh directory exists and has the right mode
  if [ ! -d ${key_path} ]; then
    mkdir -p ${key_path}
    chmod 700 ${key_path}
  fi

  # Ensure a full keypair exists
  if [ ! -f "${key_file}" -o ! -f "${key_file}.pub" ]; then

    # Regenrate public key if private key exists
    if [ -f "${key_file}" ]; then
      ssh-keygen -f ${key_file} -y > ${key_file}.pub
    fi

    # Delete public key if private key missing
    if [ ! -f "${key_file}" ]; then
      rm -f ${key_file}.pub
    fi

    # Regenerate keypair if both keys missing
    if [ ! -f "${key_file}" -a ! -f "${key_file}.pub" ]; then
      ssh-keygen -t rsa -f ${key_file} -N ''
    fi

  fi

  # Ensure that the public key is included in the authorized_keys
  # for the default root directory and the current home directory
  key_content=$(cat "${key_file}.pub")
  if ! grep -q "${key_content}" ${key_path}/authorized_keys; then
    echo "${key_content}" | tee -a ${key_path}/authorized_keys
  fi
}

function exit_state {
  set +x
  TOTALSECONDS="$(( $(date +%s) - STARTTIME ))"
  info_block "Run Time = ${TOTALSECONDS} seconds || $((TOTALSECONDS / 60)) minutes"
  if [ "${1}" == 0 ];then
    info_block "Status: Success"
  else
    info_block "Status: Failure"
  fi
  exit ${1}
}

function exit_success {
  set +x
  exit_state 0
}

function exit_fail {
  set +x
  info_block "Error Info - $@"
  exit_state 1
}

function print_info {
  PROC_NAME="- [ $@ ] -"
  printf "\n%s%s\n" "$PROC_NAME" "${LINE:${#PROC_NAME}}"
}

function info_block {
  echo "${LINE}"
  print_info "$@"
  echo "${LINE}"
}

function get_repos_info {
  for i in /etc/apt/sources.list /etc/apt/sources.list.d/* /etc/yum.conf /etc/yum.repos.d/* /etc/zypp/repos.d/*; do
    if [ -f "${i}" ]; then
      echo -e "\n$i"
      cat $i
    fi
  done
}

## Signal traps --------------------------------------------------------------
# Trap all Death Signals and Errors
trap "exit_fail ${LINENO} $? 'Received STOP Signal'" SIGHUP SIGINT SIGTERM
trap "exit_fail ${LINENO} $?" ERR

## Pre-flight check ----------------------------------------------------------
# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
  info_block "This script must be run as root"
  exit_state 1
fi

# Check that we are in the root path of the cloned repo
if [ ! -d "scripts" -a ! -d "playbooks" ]; then
  info_block "** ERROR **"
  echo "Please execute this script from the root directory of the cloned source code."
  echo -e "Example: /opt/mnaiov2\n"
  exit_state 1
fi

## Exports -------------------------------------------------------------------
# Export known paths
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH}"

# Export the home directory just in case it's not set
export HOME="/root"

