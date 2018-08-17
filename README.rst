Red Hat OSP Multi-Node AIO
################################
:date: 2018-08-03
:tags: rackspace, openstack, osp, redhat
:category: \*openstack, \*nix, \*redhat


About this repository
---------------------

Note: This is a WIP and by no means stable or final yet.

This repository is for generating a Multi-Node All in One stack of
Red Hat's OpenStack Platform (OSP).  It's done using a single OnMetal
host from the Rackspace Public Cloud using Ubuntu 18.04.  This repo
will install:

* Set up an UnderCloud (director) VM running Triple-O
* Provision all the VMs into the appropriate roles using VirtualBMC
  and Ironic provision
* Create an OverCloud running Red Hat's Openstack Distribution.  

This repo is intended for running an easily generated environment of OSP
for development, lab testing, training, upgrades, and gate testing changes.

This is a forked version of the Multi Node AIO repo from Openstack
Ansible OPS so it should work similar but they are several environmental changes.

TODO
----

* Overcloud configuation, using basics right now, but need to plug into all MNAIO
  networks.

Process
-------

Create at least one physical host that has public network access and is running
an Ubuntu 18.04 LTS Operating system. System assumes that you have an
unpartitioned device with at least 1TB of storage, however you can customize the
size of each VM volume by setting the option ``${VM_DISK_SIZE}``. If you're
using the Rackspace OnMetal servers the drive partitioning will be done for you
by detecting the largest unpartitioned device. If you're doing the deployment on
something other than a Rackspace OnMetal server you may need to set the
``${DATA_DISK_DEVICE}`` variable accordingly. the playbooks will look for a
volume group named "vg01", if this volume group exists no partitioning or setup
on the data disk will take place. To effectively use this process for testing
it's recommended that the host machine have at least 32GiB of RAM.

===========    ========   ============
Physical Host Specs known to work well
--------------------------------------
 CPU CORES      MEMORY     DISK SPACE
===========    ========   ============
    20           124GB       1.3TB
===========    ========   ============

These specs are covered by the Rackspace OnMetal-IO v1/2 Servers.

Set the variables to configure the Red Hat environment, you'll need to specify the
location of the RHEL 7.5 ISO which will be retrieved and extracted automatically.

.. code-block:: bash

    export REDHAT_ISO_URL="http://location_of/rhel-7.5.iso"
    export REDHAT_USERNAME="rhel_username"
    export REDHAT_PASSWORD="rhel_password"
    export REDHAT_CONSUMER_NAME="name_of_instance_to_be_registered"
    export REDHAT_POOL_ID="pool_id"
    export REDHAT_OSP_VERSION="13" # optional, defaults to 13

When your ready, run the build script by executing ``bash ./build.sh``. The
build script current executes a kickstart deployment of RHEL OSP Director,
creates the undercloud and overcloud.

Once completed, you can access the GUIs using the sshuttle project:

https://github.com/sshuttle/sshuttle

.. code-block:: bash

    sshuttle -e "ssh" -r root@ip_of_mnaio 192.168.24.0/24

Then you can hit the undercloud GUI at https://192.168.24.2 or horizon at
https://192.168.24.9 (may vary on deployment).

You can also access the director vm directly and use the CLI:

.. code-block:: bash

    ssh stack@director
    source stackrc
    openstack baremetal node list
    source overcloudrc
    nova list


Post Deployment
---------------

Once deployed you can use virt-manager to manage the KVM instances on the host,
similar to a DRAC or ILO.

LINUX:
    If you're running a linux system as your workstation simply install
    virt-manager from your package manager and connect to the host via
    QEMU/KVM:SSH

OSX:
    If you're running a MAC you can install https://www.xquartz.org/ to have
    access to a X11 client, then make use of X over SSH to connect to the
    virt-manager application. Using X over SSH is covered in
    https://www.cyberciti.biz/faq/apple-osx-mountain-lion-mavericks-install-xquartz-server/
    Basically load XQuartz, ssh -Y <ip_of_mnaio> and then run virt-manager.
    This should provide a view of all VMs and you can watch consoles during
    install.

WINDOWS:
    If you're running Windows, you can install virt-viewer from the KVM Download
    site.
    https://virt-manager.org/download/


Deployment screenshot
^^^^^^^^^^^^^^^^^^^^^

.. image:: screenshots/virt-manager-screenshot.jpeg
    :scale: 50 %
    :alt: Screen shot of virt-manager and deployment in action
    :align: center

Deployments can be accessed and monitored via virt-manager


Console Access
^^^^^^^^^^^^^^

.. image:: screenshots/console-screenshot.jpeg
    :scale: 50 %
    :alt: Screen shot of virt-manager console
    :align: center

The root password for all VMs is "**secrete**". This password is being set
within the pre-seed files under the "Users and Password" section. If you want
to change this password please edit the pre-seed files.


``build.sh`` Options
--------------------

Set an external inventory used for the MNAIO:
  ``MNAIO_INVENTORY=${MNAIO_INVENTORY:-playbooks/inventory}``

Set to instruct the preseed what the default network is expected to be:
  ``DEFAULT_NETWORK="${DEFAULT_NETWORK:-eth0}"``

Set the VM disk size in gigabytes:
  ``VM_DISK_SIZE="${VM_DISK_SIZE:-252}"``

Instruct the system do all of the required host setup:
  ``SETUP_HOST=${SETUP_HOST:-true}``

Instruct the system do all of the required PXE setup:
  ``SETUP_PXEBOOT=${SETUP_PXEBOOT:-true}``

Instruct the system do all of the required DHCPD setup:
  ``SETUP_DHCPD=${SETUP_DHCPD:-true}``

Instruct the system to Kick all of the VMs:
  ``DEPLOY_VMS=${DEPLOY_VMS:-true}``

Instruct the VM to use the selected image, eg. ubuntu-16.04-amd64:
  ``DEFAULT_IMAGE=${DEFAULT_IMAGE:-ubuntu-16.04-amd64}``

Instruct the system to configure iptables prerouting rules for connecting to
VMs from outside the host:
  ``CONFIG_PREROUTING=${CONFIG_PREROUTING:-true}``

Instruct the system to use a set amount of ram for cinder VM type:
  ``CINDER_VM_SERVER_RAM=${CINDER_VM_SERVER_RAM:-2048}``

Instruct the system to use a set amount of ram for compute VM type:
  ``COMPUTE_VM_SERVER_RAM=${COMPUTE_VM_SERVER_RAM:-8196}``

Instruct the system to use a set amount of ram for infra VM type:
  ``INFRA_VM_SERVER_RAM=${INFRA_VM_SERVER_RAM:-8196}``

Instruct the system to use a set amount of ram for load balancer VM type:
  ``LOADBALANCER_VM_SERVER_RAM=${LOADBALANCER_VM_SERVER_RAM:-1024}``

Instruct the system to use a set amount of ram for the logging VM type:
  ``LOGGING_VM_SERVER_RAM=${LOGGING_VM_SERVER_RAM:-1024}``

Instruct the system to use a set amount of ram for the swift VM type:
  ``SWIFT_VM_SERVER_RAM=${SWIFT_VM_SERVER_RAM:-1024}``

Instruct the system to use a customized iPXE kernel:
  ``IPXE_KERNEL_URL=${IPXE_KERNEL_URL:-'http://boot.ipxe.org/ipxe.lkrn'}``

Instruct the system to use a customized iPXE script during boot of VMs:
  ``IPXE_PATH_URL=${IPXE_PATH_URL:-''}``


Re-kicking VM(s)
----------------

Re-kicking a VM is as simple as stopping a VM, delete the logical volume, create
a new logical volume, start the VM. The VM will come back online, pxe boot, and
install the base OS.

.. code-block:: bash

    virsh destroy "${VM_NAME}"
    lvremove "/dev/mapper/vg01--${VM_NAME}"
    lvcreate -L 60G vg01 -n "${VM_NAME}"
    virsh start "${VM_NAME}"


To rekick all VMs, simply re-execute the ``deploy-vms.yml`` playbook and it will
do it automatically.

.. code-block:: bash

    ansible-playbook -i playbooks/inventory playbooks/deploy-vms.yml

Rerunning the build script
--------------------------

The build script can be rerun at any time. By default it will re-kick the entire
system, destroying all existing VM's.

Snapshotting an environment before major testing
------------------------------------------------

Running a snapshot on all of the vms before doing major testing is wise as it'll
give you a restore point without having to re-kick the cloud. You can do this
using some basic ``virsh`` commands and a little bash.

.. code-block:: bash

    for instance in $(virsh list --all --name); do
      virsh snapshot-create-as --atomic --name $instance-kilo-snap --description "saved kilo state before liberty upgrade" $instance
    done


Once the previous command is complete you'll have a collection of snapshots
within all of your infrastructure hosts. These snapshots can be used to restore
state to a previous point if needed. To restore the infrastructure hosts to a
previous point, using your snapshots, you can execute a simple ``virsh``
command or the following bash loop to restore everything to a known point.

.. code-block:: bash

    for instance in $(virsh list --all --name); do
      virsh snapshot-revert --snapshotname $instance-kilo-snap --running $instance
    done

Using a file-based backing store with thin-provisioned VM's
-----------------------------------------------------------

If you wish to use a file-based backing store (instead of the default LVM-based
backing store) for the VM's, then set the following option before executing
``build.sh``.

.. code-block:: bash

    export MNAIO_ANSIBLE_PARAMETERS="-e default_vm_disk_mode=file"
    ./build.sh

If you wish to save the current file-based images in order to implement a
thin-provisioned set of VM's which can be saved and re-used, then use the
``save-vms.yml`` playbook. This will stop the VM's and save the files to
``/var/lib/libvirt/images/*-base.img``. Re-executing the ``deploy-vms.yml``
playbook afterwards will rebuild the VMs from those images.

.. code-block:: bash

    ansible-playbook -i playbooks/inventory playbooks/save-vms.yml
    ansible-playbook -i playbooks/inventory -e default_vm_disk_mode=file playbooks/deploy-vms.yml

To disable this default functionality when re-running ``build.sh`` set the
build not to use the snapshots as follows.

.. code-block:: bash

    export MNAIO_ANSIBLE_PARAMETERS="-e default_vm_disk_mode=file -e vm_use_snapshot=no"
    ./build.sh
