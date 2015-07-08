#!/bin/sh

# Pull down the images
docker pull registry.access.redhat.com/openshift3/ose-haproxy-router:v3.0.0.0
docker pull registry.access.redhat.com/openshift3/ose-deployer:v3.0.0.0
docker pull registry.access.redhat.com/openshift3/ose-sti-builder:v3.0.0.0
docker pull registry.access.redhat.com/openshift3/ose-sti-image-builder:v3.0.0.0
docker pull registry.access.redhat.com/openshift3/ose-docker-builder:v3.0.0.0
docker pull registry.access.redhat.com/openshift3/ose-pod:v3.0.0.0
docker pull registry.access.redhat.com/openshift3/ose-docker-registry:v3.0.0.0
# docker pull registry.access.redhat.com/openshift3/sti-basicauthurl
docker pull registry.access.redhat.com/openshift3/ose-keepalived-ipfailover:v3.0.0.0


# Image streams
docker pull registry.access.redhat.com/openshift3/ruby-20-rhel7
docker pull registry.access.redhat.com/openshift3/nodejs-010-rhel7
docker pull registry.access.redhat.com/openshift3/perl-516-rhel7
docker pull registry.access.redhat.com/openshift3/python-33-rhel7
docker pull registry.access.redhat.com/openshift3/mysql-55-rhel7
docker pull registry.access.redhat.com/openshift3/postgresql-92-rhel7
docker pull registry.access.redhat.com/openshift3/mongodb-24-rhel7

#docker pull registry.access.redhat.com/jboss-webserver-3/tomcat7-openshift
#docker pull registry.access.redhat.com/jboss-webserver-3/tomcat8-openshift
#docker pull registry.access.redhat.com/jboss-eap-6/eap-openshift


docker pull openshift/ruby-20-centos7
docker pull openshift/nodejs-010-centos7
docker pull openshift/perl-516-centos7
docker pull openshift/python-33-centos7
docker pull openshift/wildfly-8-centos