#!/bin/sh
#
# Params
#   $1: hostname
#   $2: dnsmasq_server_ip
#   $3: poolID
#   $4: disk device
#
_HOSTNAME=$1
_DNSMASQ_SERVER_IP=$2
_POOLID=$3
_DISK_DEVICE=$4

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Copy ssh key and add to authorized_keys. All boxes same key.
mkdir -p ~/.ssh
cp ${DIR}/id_rsa ~/.ssh/
cat ${DIR}/id_rsa.pub >>  ~/.ssh/authorized_keys
echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

subscription-manager attach --pool=${_POOLID}
subscription-manager repos --disable='*'
subscription-manager repos --enable rhel-7-server-rpms --enable rhel-7-server-extras-rpms --enable rhel-7-server-optional-rpms  --enable rhel-7-server-ose-3.0-rpms
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-beta
yum -y install deltarpm
#yum -y remove NetworkManager*
yum -y install wget vim-enhanced net-tools bash-completion bind-utils system-storage-manager tree python-virtualenv
yum -y update

# Setup hostnames
hostnamectl --static set-hostname ${_HOSTNAME}.example.com

# Install docker
yum -y install docker

# Run docker related stuff
# Docker provides a very small volume for the docker pool
# The VM comes with a separate disk that is supposed to host all the docker images
# the following commands prepare everything.

# Stop docker
systemctl stop docker > /dev/null 2>&1 || :

# Set registry to use
#sed -i -e "s/registry\.access\.redhat\.com/ose3-registry:5000/" /etc/sysconfig/docker
#sed -i -e "s/^# BLOCK_REGISTRY=.*/BLOCK_REGISTRY='--block-registry registry\.access\.redhat\.com --block-registry docker\.io '/" /etc/sysconfig/docker
sed -i -e "s/^# INSECURE_REGISTRY=.*/INSECURE_REGISTRY='--insecure-registry 0\.0\.0\.0\/0 '/" /etc/sysconfig/docker

# Remove the default docker-pool
lvremove -f VolGroup00/docker-pool

# Remove any files and directories from the default installation
rm -rf /var/lib/docker/*

# Make docker use our dedicated disk for docker related stuff
cat <<EOF > /etc/sysconfig/docker-storage-setup
DEVS=${_DISK_DEVICE}
VG=docker-vg
SETUP_LVM_THIN_POOL=yes
EOF

# Run docker-storage-setup
docker-storage-setup

# Finally start docker
systemctl enable docker && sudo systemctl start docker

# usermod -a -G docker vagrant
# chown root:docker /var/run/docker.sock

# Configure networking
echo "dns=none" >>  /etc/NetworkManager/NetworkManager.conf
cp /etc/resolv.conf /etc/resolv.conf.orig
echo "#Custom resolv.conf made for Openshift" > /etc/resolv.conf
echo "search example.com" >> /etc/resolv.conf
echo "nameserver ${_DNSMASQ_SERVER_IP}" >> /etc/resolv.conf
cat /etc/resolv.conf.orig >> /etc/resolv.conf
systemctl restart NetworkManager

# Add aliases and disable truncating log lines
echo "alias tailfmaster='journalctl -f -u openshift-master' -l " >> ~/.bashrc
echo "alias tailfnode='journalctl -f -u openshift-node' -l " >> ~/.bashrc

# Add My docker function aliases
curl https://raw.githubusercontent.com/jorgemoralespou/scripts/master/docker/bash_aliases_docker.txt -o ~/.docker_aliases
echo "source ~/.docker_aliases" >> ~/.bashrc
