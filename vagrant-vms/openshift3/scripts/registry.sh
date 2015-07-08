#!/bin/sh

#
# Common functionality for every box
#
subscription-manager attach --pool=8a85f9874011071c01407da00b997cb2
subscription-manager repos --disable='*'
subscription-manager repos --enable rhel-7-server-rpms --enable rhel-7-server-extras-rpms --enable rhel-7-server-optional-rpms  --enable rhel-server-7-ose-beta-rpms
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-beta
yum -y install deltarpm
yum -y remove NetworkManager*
yum -y install wget vim-enhanced net-tools bash-completion bind-utils system-storage-manager git
yum -y update

# Install docker
yum -y install docker
sed -i -e "s/^OPTIONS='--selinux-enabled'/OPTIONS='--selinux-enabled --insecure-registry 0\.0\.0\.0\/0'/" /etc/sysconfig/docker
systemctl stop docker > /dev/null 2>&1 || :
# usermod -a -G docker vagrant
systemctl enable docker && sudo systemctl start docker
# chown root:docker /var/run/docker.sock

# USE THE REGISTRY AS DNS SERVER
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
hostnamectl --static set-hostname ose3-registry.example.com


REGISTRY=ose3-registry:5000

#
# Install the registry
#
mkdir /opt/docker-registry
chmod 777 /opt/docker-registry

# Enable a systemd for the registry, so it starts in next boots
# https://docs.docker.com/articles/host_integration/
cat > /etc/systemd/system/docker-registry.service <<EOF
[Unit]
Description=Docker Registry container
Requires=docker.service
After=docker.service

[Service]
Restart=always
ExecStart=/usr/bin/docker run --privileged  --rm --name docker-registry -p 5000:5000 -v /opt/docker-registry:/registry --env REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=/registry registry:2.0
ExecStop=/usr/bin/docker kill docker-registry

[Install]
WantedBy=local.target
EOF
# Enable, register and start service
systemctl daemon-reload
systemctl start docker-registry.service
systemctl status docker-registry.service
systemctl enable docker-registry.service


#
# Download images to share
#
redhat_registry_images=( \
        openshift3_beta/ose-haproxy-router:v0.4.3.2 \
        openshift3_beta/ose-deployer:v0.4.3.2 \
        openshift3_beta/ose-sti-builder:v0.4.3.2 \
        openshift3_beta/ose-docker-builder:v0.4.3.2 \
        openshift3_beta/ose-pod:v0.4.3.2 \
        openshift3_beta/ose-docker-registry:v0.4.3.2 \
        openshift3_beta/sti-basicauthurl:latest \
        openshift3_beta/ruby-20-rhel7 \
        openshift3_beta/mysql-55-rhel7 \
)

docker_registry_images=( \
        openshift/hello-openshift \
        openshift/ruby-20-centos7 \
)

redhat_registry_imagestream=( \
        openshift3_beta/ruby-20-rhel7 \
        openshift3_beta/nodejs-010-rhel7 \
        openshift3_beta/perl-516-rhel7 \
        openshift3_beta/python-33-rhel7 \
        openshift3_beta/mysql-55-rhel7 \
        openshift3_beta/postgresql-92-rhel7 \
        openshift3_beta/mongodb-24-rhel7 \
        jboss-webserver-3/tomcat7-openshift \
        jboss-webserver-3/tomcat8-openshift \
        jboss-eap-6/eap-openshift \
)

docker_registry_imagestream=( \
        openshift/ruby-20-centos7 \
        openshift/nodejs-010-centos7 \
        openshift/perl-516-centos7 \
        openshift/python-33-centos7 \
        openshift/wildfly-8-centos \
)

for element in $(seq 0 $((${#redhat_registry_images[@]} - 1)))
do
  echo "===" 
  echo "Installing registry.access.redhat.com/${redhat_registry_images[$element]} into local registry ($REGISTRY)"  
  docker pull registry.access.redhat.com/${redhat_registry_images[$element]}
  docker tag -f  registry.access.redhat.com/${redhat_registry_images[$element]} $REGISTRY/${redhat_registry_images[$element]}
  docker push $REGISTRY/${redhat_registry_images[$element]}
  echo "  "
done

for element in $(seq 0 $((${#docker_registry_images[@]} - 1)))
do
  echo "===" 
  echo "Installing ${docker_registry_images[$element]} into local registry ($REGISTRY)"  
  docker pull ${docker_registry_images[$element]}
  docker tag -f  ${docker_registry_images[$element]} $REGISTRY/${docker_registry_images[$element]}
  docker push $REGISTRY/${docker_registry_images[$element]}
  echo "  "
done

# Imagestreams
for element in $(seq 0 $((${#redhat_registry_imagestream[@]} - 1)))
do
  echo "===" 
  echo "Installing ${redhat_registry_imagestream[$element]} into local registry ($REGISTRY)"  
  docker pull registry.access.redhat.com/${redhat_registry_imagestream[$element]}
  docker tag -f  registry.access.redhat.com/${redhat_registry_imagestream[$element]} $REGISTRY/${redhat_registry_imagestream[$element]}
  docker push $REGISTRY/${redhat_registry_imagestream[$element]}
  echo "  "
done

# Imagestreams
for element in $(seq 0 $((${#docker_registry_imagestream[@]} - 1)))
do
  echo "===" 
  echo "Installing ${docker_registry_imagestream[$element]} into local registry ($REGISTRY)"  
  docker pull ${docker_registry_imagestream[$element]}
  docker tag -f  ${docker_registry_imagestream[$element]} $REGISTRY/${docker_registry_imagestream[$element]}
  docker push $REGISTRY/${docker_registry_imagestream[$element]}
  echo "  "
done
