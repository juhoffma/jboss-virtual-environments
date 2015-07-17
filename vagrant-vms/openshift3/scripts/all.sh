#!/bin/sh
#
# Params
#   $1: hostname
#   $2: dnsmasq_server_ip
#   $3: poolID
#
_HOSTNAME=$1
_DNSMASQ_SERVER_IP=$2
_POOLID=$3

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

# EXTEND STORAGE FOR DOCKER: http://unpoucode.blogspot.com.es/2015/06/docker-and-devicemappers-thinpool-in.html
pvcreate /dev/vdb
vgextend VolGroup00  /dev/vdb
lvextend -l 100%FREE /dev/VolGroup00/docker-pool

# Install docker
yum -y install docker

# Set registry to use
#sed -i -e "s/registry\.access\.redhat\.com/ose3-registry:5000/" /etc/sysconfig/docker
#sed -i -e "s/^# BLOCK_REGISTRY=.*/BLOCK_REGISTRY='--block-registry registry\.access\.redhat\.com --block-registry docker\.io '/" /etc/sysconfig/docker
sed -i -e "s/^# INSECURE_REGISTRY=.*/INSECURE_REGISTRY='--insecure-registry 0\.0\.0\.0\/0 '/" /etc/sysconfig/docker

systemctl stop docker > /dev/null 2>&1 || :
# usermod -a -G docker vagrant
systemctl enable docker && sudo systemctl start docker
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
