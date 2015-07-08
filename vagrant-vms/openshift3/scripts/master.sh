#!/bin/sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Install EPEL and ansible.
yum -y install http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
sed -i -e "s/^enabled=1/enabled=0/" /etc/yum.repos.d/epel.repo
yum -y --enablerepo=epel install ansible


# Get the ansible installer and training material
cd
rm -rf openshift-ansible
git clone https://github.com/openshift/openshift-ansible -b v3.0.0

# Configure the hosts
/bin/cp ${DIR}/hosts /etc/ansible/

# Install OpenShift. Execute ansible playbook install
ansible-playbook ~/openshift-ansible/playbooks/byo/config.yml

# Clone the trainign repo
cd
rm -rf training
git clone https://github.com/openshift/training


# Add users
useradd joe
useradd alice
htpasswd -b /etc/openshift/openshift-passwd joe redhat
htpasswd -b /etc/openshift/openshift-passwd alice redhat


# Create a service account for the registry to run as
echo '{"kind":"ServiceAccount","apiVersion":"v1","metadata":{"name":"registry"}}' | oc create -f -

# Add the service account to the list of users allowed to run privileged containers
oc get scc privileged -o json > /tmp/scc.json
sed -i '/"users":/a "system:serviceaccount:default:registry",' /tmp/scc.json
oc update -f /tmp/scc.json
rm /tmp/scc.json

# Create the registry and specify it should use the service account
mkdir -p /etc/openshift/registry
oadm registry --service-account=registry --config=/etc/openshift/master/admin.kubeconfig --credentials=/etc/openshift/master/openshift-registry.kubeconfig --selector='region=infra' --mount-host=/etc/openshift/registry --images='registry.access.redhat.com/openshift3/ose-${component}:${version}'
# NOTE: Registry is not secured

# Create a router
oadm router router --replicas=1 --selector='region=infra' --credentials='/etc/openshift/master/openshift-router.kubeconfig' --images='registry.access.redhat.com/openshift3/ose-${component}:${version}'
# NOTE: Router is non SSL

# Adding Image Streams
# For RHEL
# oc create -f /usr/share/openshift/examples/image-streams/image-streams-rhel7.json -n openshift
# For CentOS
# oc create -f /usr/share/openshift/examples/image-streams/image-streams-centos7.json -n openshift
# Databases
# oc create -f /usr/share/openshift/examples/db-templates -n openshift
# NOTE: Above installed during installation
git clone https://github.com/jboss-openshift/application-templates.git -b  ose-v1.0.0 /usr/share/openshift/examples/xPaaS-Final-OSE-v1.0.0
oc create -f /usr/share/openshift/examples/xPaaS-Final-OSE-v1.0.0/jboss-image-streams.json -n openshift


# Creating the templates
# oc create -f /usr/share/openshift/examples/quickstart-templates -n openshift
# NOTE: Above installed during installation
oc create -f /usr/share/openshift/examples/xPaaS-Final-OSE-v1.0.0/amq -n openshift
oc create -f /usr/share/openshift/examples/xPaaS-Final-OSE-v1.0.0/eap -n openshift
oc create -f /usr/share/openshift/examples/xPaaS-Final-OSE-v1.0.0/webserver -n openshift
# oc create -f /usr/share/openshift/examples/xPaaS-Final-OSE-v1.0.0/secrets
