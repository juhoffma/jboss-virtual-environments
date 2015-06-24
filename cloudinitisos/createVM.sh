#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# COMMON FUNCTIONS =============================

SETCOLOR_SUCCESS="echo -en \\033[1;32m"
SETCOLOR_INFO="echo -en \\033[1;36m"
SETCOLOR_FAILURE="echo -en \\033[1;31m"
SETCOLOR_NORMAL="echo -en \\033[0;39m"

echo_ok() {
  $SETCOLOR_SUCCESS
  echo -n $1
  $SETCOLOR_NORMAL
  echo ""
  return 0
}

echo_info() {
  $SETCOLOR_INFO
  echo -n $1
  $SETCOLOR_NORMAL
  echo ""
  return 0
}

echo_nook() {
  $SETCOLOR_FAILURE
  echo -n $1
  $SETCOLOR_NORMAL
  echo ""
  return 0
}

exit_error() {
   echo_nook "$1"
   exit 255
}

function fail_if_not_root {
   if [ "$UID" -ne 0 ]
   then
      echo_nook "To run this script you need root permissions (either root or sudo)"
      exit
   fi 
}

# =============================

: ${ATOMIC_BASE_IMAGE:="rhel-atomic-host-7.qcow2"}
: ${LIBVIRT_IMAGES:="/var/lib/libvirt/images"}

[ $# -ne 1 ] && exit_error "You must specify a directory for the cloudinit data"

_name=$1

echo_info "Creating the user suplied cloud init info"
mkdir -p ${DIR}/target
pushd ${_name}
genisoimage -output ${DIR}/target/${_name}-cidata.iso -volid cidata -joliet -rock user-data meta-data
popd
echo_ok "Cloud-init iso file succesfully created at: ${DIR}/target/${_name}-cidata.iso"

fail_if_not_root

echo_info "Creating a copy on write HDD based on ${ATOMIC_BASE_IMAGE}"
qemu-img create -f qcow2 -o backing_file=${LIBVIRT_IMAGES}/${ATOMIC_BASE_IMAGE} ${LIBVIRT_IMAGES}/${_name}.qcow2
echo_ok "Copy on write HDD succesfully created with name: ${_name}.qcow2"

echo_info "Creating a VM with name ${_name}"
virt-install --import --name ${_name} --ram 1024 --vcpus 2 --disk path=${LIBVIRT_IMAGES}/${_name}.qcow2,format=qcow2,bus=virtio --disk path=$DIR/target/${_name}-cidata.iso,device=cdrom --network bridge=virbr0 --force
#qemu-kvm -name ${_name} -m 1024 -hda ${_name}.qcow2 -cdrom atomic01-cidata.iso -netdev bridge,br=virbr0,id=net0 -device virtio-net-pci,netdev=net0 -display sdl
echo_ok "VM succesfully created with name ${_name}. Remember user is cloud-init"
