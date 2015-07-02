#!/bin/sh

# Install EPEL and ansible.
yum -y install http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
sed -i -e "s/^enabled=1/enabled=0/" /etc/yum.repos.d/epel.repo
yum -y --enablerepo=epel install ansible


# Execute ansible playbook install
# cd
# git clone https://github.com/detiber/openshift-ansible.git -b v3-beta3
# /bin/cp -r ~/training/beta3/ansible/* /etc/ansible/
# ansible-playbook ~/openshift-ansible/playbooks/byo/config.yml

# Add users
useradd joe
useradd alice

# Install htpasswd
yum -y install httpd-tools
touch /etc/openshift-passwd
htpasswd -b /etc/openshift-passwd joe redhat
htpasswd -b /etc/openshift-passwd alice redhat

sed -i -e 's/name: anypassword/name: apache_auth/' \
-e 's/kind: AllowAllPasswordIdentityProvider/kind: HTPasswdPasswordIdentityProvider/' \
-e '/kind: HTPasswdPasswordIdentityProvider/i \      file: \/etc\/openshift-passwd' \
/etc/openshift/master.yaml