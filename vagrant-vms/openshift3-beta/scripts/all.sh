#!/bin/sh
#
# Params
#   $1: hostname
#
DNSMASQ_SERVER_IP=192.168.133.100

subscription-manager attach --pool=8a85f9874011071c01407da00b997cb2
subscription-manager repos --disable='*'
subscription-manager repos --enable rhel-7-server-rpms --enable rhel-7-server-extras-rpms --enable rhel-7-server-optional-rpms  --enable rhel-server-7-ose-beta-rpms
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-beta
yum -y install deltarpm
#yum -y remove NetworkManager*
yum -y install wget vim-enhanced net-tools bash-completion bind-utils system-storage-manager git
yum -y update

# Setup hostnames
hostnamectl --static set-hostname $1.example.com

# Install docker
yum -y install docker

# Set registry to use
sed -i -e "s/registry\.access\.redhat\.com/ose3-registry:5000/" /etc/sysconfig/docker
sed -i -e "s/^# BLOCK_REGISTRY=.*/BLOCK_REGISTRY='--block-registry registry\.access\.redhat\.com --block-registry docker\.io '/" /etc/sysconfig/docker
sed -i -e "s/^# INSECURE_REGISTRY=.*/INSECURE_REGISTRY='--insecure-registry 0\.0\.0\.0\/0 '/" /etc/sysconfig/docker

systemctl stop docker > /dev/null 2>&1 || :
# usermod -a -G docker vagrant
systemctl enable docker && sudo systemctl start docker
# chown root:docker /var/run/docker.sock

# Setup resolv.conf to go to dnsmasq server in the registry
sed -i -e "1s/^/nameserver ${DNSMASQ_SERVER_IP}\n /" /etc/resolv.conf


# Add aliases
echo "alias tailfmaster='journalctl -f -u openshift-master' " >> ~/.bashrc
echo "alias tailfnode='journalctl -f -u openshift-node' " >> ~/.bashrc
echo "alias tailfsdnmaster='journalctl -f -u openshift-sdn-master' " >> ~/.bashrc
echo "alias tailfsdnnode='journalctl -f -u openshift-sdn-node' " >> ~/.bashrc
