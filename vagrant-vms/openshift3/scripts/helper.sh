#!/bin/sh

#
# Common functionality for every box
#
#   $1: hostname
#   $2: poolID
#
_HOSTNAME=$1
_POOLID=$2

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Executing this script: $0 $1 $2 $3"

# Copy ssh key and add to authorized_keys. All boxes same key.
mkdir -p ~/.ssh
cp ${DIR}/id_rsa ~/.ssh/
cat ${DIR}/id_rsa.pub >>  ~/.ssh/authorized_keys



subscription-manager attach --pool=${_POOLID}
subscription-manager repos --disable='*'
subscription-manager repos --enable rhel-7-server-rpms --enable rhel-7-server-extras-rpms --enable rhel-7-server-optional-rpms  --enable rhel-7-server-ose-3.0-rpms
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-beta
yum -y install deltarpm
yum -y install wget vim-enhanced net-tools bash-completion bind-utils system-storage-manager git
yum -y update

# Install docker
yum -y install docker
sed -i -e "s/^OPTIONS='--selinux-enabled'/OPTIONS='--selinux-enabled --insecure-registry 0\.0\.0\.0\/0'/" /etc/sysconfig/docker
systemctl stop docker > /dev/null 2>&1 || :
# usermod -a -G docker vagrant
systemctl enable docker && sudo systemctl start docker
# chown root:docker /var/run/docker.sock

# USE AS DNS SERVER
# Enable and set dnsmasq
cat > /etc/dnsmasq.conf <<EOF
strict-order
domain-needed
local=/example.com/
bind-dynamic
address=/.cloudapps.example.com/192.168.133.2
log-queries
#conf-file=/etc/dnsmasq.more.conf
conf-dir=/etc/dnsmasq.d
EOF
systemctl enable dnsmasq
systemctl start dnsmasq
systemctl status dnsmasq


# Setup hostnames
hostnamectl --static set-hostname ${_HOSTNAME}.example.com