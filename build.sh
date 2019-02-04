#!/usr/bin/env bash
# Copyright [2016] [Kevin Carter]
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

set -euvo

source bootstrap.sh

source ansible-env.rc

ansible mnaio_hosts \
        -i ${MNAIO_INVENTORY:-"playbooks/inventory"} \
        -m pip \
        -a "name=netaddr"

export MNAIO_ANSIBLE_PARAMETERS=${MNAIO_ANSIBLE_PARAMETERS:-""}

ansible-playbook -vv \
                 -i ${MNAIO_INVENTORY:-"playbooks/inventory"} \
                 -e setup_host=${SETUP_HOST:-"true"} \
                 -e setup_pxeboot=${SETUP_PXEBOOT:-"true"} \
                 -e setup_dhcpd=${SETUP_DHCPD:-"true"} \
                 -e deploy_vms=${DEPLOY_VMS:-"true"} \
                 -e test_osp=${TEST_OSP:-"true"} \
                 -e "tempest_tests=\"${TEMPEST_TESTS:-"--regex ^tempest.scenario.test_[^_]+_basic_ops.*smoke --blacklist-file /home/stack/tempest-blacklist.txt"}\"" \
                 -e default_network=${DEFAULT_NETWORK:-"eth0"} \
                 -e default_image=${DEFAULT_IMAGE:-"rhel-7.5-amd64"} \
                 -e vm_disk_size=${VM_DISK_SIZE:-92160} \
                 -e http_proxy=${http_proxy:-''} \
                 -e config_prerouting=${CONFIG_PREROUTING:-"true"} \
                 -e ceph_vm_server_ram=${CEPH_VM_SERVER_RAM:-"4096"} \
                 -e compute_vm_server_ram=${COMPUTE_VM_SERVER_RAM:-"8196"} \
                 -e controller_vm_server_ram=${CONTROLLER_VM_SERVER_RAM:-"16384"} \
                 -e director_vm_server_ram=${DIRECTOR_VM_SERVER_RAM:-"16384"} \
                 -e swift_vm_server_ram=${SWIFT_VM_SERVER_RAM:-"4096"} \
                 -e director_vm_server_vcpus=${DIRECTOR_VM_SERVER_VCPUS:-"8"} \
                 -e ipxe_kernel_url=${IPXE_KERNEL_URL:-"http://boot.ipxe.org/ipxe.lkrn"} \
                 -e redhat_iso_url=${REDHAT_ISO_URL:-""} \
                 -e redhat_base_url=${REDHAT_BASE_URL:-"http://192.168.24.254/distros/redhat/7.5/"} \
                 -e redhat_username=${REDHAT_USERNAME:-""} \
                 -e redhat_password=${REDHAT_PASSWORD:-""} \
                 -e redhat_consumer_name=${REDHAT_CONSUMER_NAME:-""} \
                 -e redhat_pool_id=${REDHAT_POOL_ID:-""} \
                 -e redhat_osp_version=${REDHAT_OSP_VERSION:-"13"} \
                 -e redhat_overcloud_register=${REDHAT_OVERCLOUD_REGISTER:-'false'} \
                 -e enable_ceph_storage=${ENABLE_CEPH_STORAGE:-"true"} \
                 -e enable_ceph_rgw=${ENABLE_CEPH_RGW:-"true"} \
                 -e ceph_osds_size=${ceph_osds_size:-"20480"} \
                 -e ceph_journal_size=${CEPH_JOURNAL_SIZE:-"5120"} \
                 -e enable_swift_storage=${ENABLE_SWIFT_STORAGE:-"false"} \
                 -e enable_octavia=${ENABLE_OCTAVIA:-"true"} \
                 -e enable_sahara=${ENABLE_SAHARA:-"true"} \
                 -e enable_manila=${ENABLE_MANILA:-"true"} \
                 -e enable_barbican=${ENABLE_BARBICAN:-"true"} \
                 -e enable_ovn=${ENABLE_OVN:-"false"} \
                 -e ipxe_path_url=${IPXE_PATH_URL:-""} ${MNAIO_ANSIBLE_PARAMETERS} \
                 --force-handlers \
                 --flush-cache \
                 playbooks/site.yml
