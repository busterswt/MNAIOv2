
OpenStack-Ansible Multi-Node All-in-One (MNAIO) v2
##################################################
:date: 2022-12-16
:tags: rackspace, openstack, ansible

About this repository
---------------------

This is not your grandma's MNAIO.

Full OpenStack deployment using an **existing** OpenStack-based cloud.
This is a multi-node installation using instances that are deployed using
Terraform and managed by Ansible.

The environment consists of the following:

- 1x Deploy Node (4 vCPUs, 4 GB RAM, 20 GB Disk)
- 2x Load Balancers (4 vCPUs, 4 GB RAM, 20 GB Disk)
- 3x Controllers (12 vCPUs, 32 GB RAM, 60 GB Disk)
- 3x Computes (8 vCPUs, 16 GB RAM, 40 GB Disk)

The script(s) will build and deploy OpenStack across multiple virtual
instances, and is customizable using standard OpenStack-Ansible
mechanisms.

Installation
------------

Download this repository to your local workstation or to a machine that
has access to an OpenStack-based cloud. The machine must be able to access
the OpenStack APIs. The OpenStack cloud must have the resources available
to support the instance flavors noted above.

.. code-block:: bash

    git clone https://github.com/busterswt/mnaiov2/

Prerequisites
-------------

- Ansible (>=2.3.15)
- Terraform (>=1.3.6)

From within the MNAIOv2 directory, install Ansible and required collections
with the following commands (Ubuntu 20.04):

.. code-block:: bash

    sudo apt install python3-pip
    sudo pip3 install ansible-core==2.13.5
    ansible-galaxy collection install -r requirements.yml

Install Teraform:

.. code-block:: bash

    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    sudo apt-get update && sudo apt-get install terraform=1.3.6

Overrides
---------

By default, MNAIOv2 will deploy an OpenStack cloud with the following
attributes:

- Ubuntu Focal 20.04 LTS
- OpenStack-Ansible (Master branch)
- Neutron ML2/OVS

All overrides can be set using environment variables prior to executing the
build.

``build.sh`` Options
====================

Required
^^^^^^^^

The variables here are **required**, and the deployment will fail without them.

Set the Neutron external provider network name (from undercloud)
  ``export MNAIO_OSA_EXTERNAL_NETWORK_NAME="<openstack external provider network name>"``

Set the Neutron external provider network uuid (from undercloud)
  ``export MNAIO_OSA_EXTERNAL_NETWORK_UUID="<openstack external provider network uuid>"``

Optional
^^^^^^^^

The variables here are optional, as there are defaults in place.

Set the OpenStack-Ansible branch
  ``export MNAIO_OSA_BRANCH="${MNAIO_OSA_BRANCH:-master}"``

Set the Neutron plugin (options: ml2.ovs,ml2.ovn)
  ``export MNAIO_OSA_NEUTRON_PLUGIN="${MNAIO_OSA_NEUTRON_PLUGIN:-ml2.ovs}"``

Set the instance image type (options: focal,jammy)
  ``export MNAIO_OSA_VM_IMAGE="${MNAIO_OSA_VM_IMAGE:-focal}"``

Architecture
============

Deploy
^^^^^^

- MNAIOv2 utilizes floating IPs from the "undercloud" to allow the Terraform and Ansible host to perform bootstrapping of the deployed instances.

Glance
^^^^^^

- Glance API is hosted on a single Controller node to avoid issues with uneven image distribution.

Networking
^^^^^^^^^^

(TODO)

Note to me:
- scenario where we can use "flat" external network in overcloud, but the real interface a 'vxlan' interface in undercloud

undercloud

External Provider Network
           |
           |
           |
      tenant Router
        |     |
        |     |
        |     |
- over ext prov  
- over mgmt (floating)
- over overlay

Deployment
----------

To deploy an MNAIOv2 environment, simply execute the following:

.. code-block:: bash

    export OS_USERNAME=<openstack username>
    export OS_TENANT_NAME=<openstack tenant/project name>
    export OS_PASSWORD=<openstack password>
    export OS_AUTH_URL=<openstack auth url>
    bash build.sh

To destroy an MNAIOv2 environment, simply execute the following:

.. code-block:: bash

    export OS_USERNAME=<openstack username>
    export OS_TENANT_NAME=<openstack tenant/project name>
    export OS_PASSWORD=<openstack password>
    export OS_AUTH_URL=<openstack auth url>
    bash destroy.sh

If the VM deployment is successful, you should see the following:

.. code-block:: bash

    TASK [Finished notice] *************************************************************
    ok: [mnaio-deploy1] => {}
    
    MSG:
    
    OSA deploy running. To check on the state of this deployment, login
    to the mnaio-deploy1 VM (192.168.2.183) and attach to the "build-osa" tmux session.

To SSH to the deploy node, use the private key. Attach to the existing tmux session, as indicated:

.. code-block:: bash

    jdenton@MBP-M1 % ssh -i id_rsa_mnaio.key ubuntu@192.168.2.183
    Welcome to Ubuntu 20.04.5 LTS (GNU/Linux 5.4.0-135-generic x86_64)
    
    * Documentation:  https://help.ubuntu.com
    * Management:     https://landscape.canonical.com
    * Support:        https://ubuntu.com/advantage
    
    System information as of Sat Dec 17 00:16:49 UTC 2022
    
    System load:  0.0                Processes:             130
    Usage of /:   10.7% of 19.20GB   Users logged in:       1
    Memory usage: 8%                 IPv4 address for ens3: 172.25.1.51
    Swap usage:   0%
    
    
    0 updates can be applied immediately.
    
    New release '22.04.1 LTS' available.
    Run 'do-release-upgrade' to upgrade to it.
    
    
    Last login: Sat Dec 17 00:11:36 2022 from 192.168.6.199
    ubuntu@mnaio-deploy1:~$ sudo su
    root@mnaio-deploy1:/home/ubuntu# tmux attach

Changes to the deployment can be made in ``/etc/openstack_deploy``, and playbooks exist in ``/opt/openstack-ansible``.
