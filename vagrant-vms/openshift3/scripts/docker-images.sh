#!/bin/sh

# Pull down the images
docker pull openshift3_beta/ose-haproxy-router:v0.4.3.2
docker pull openshift3_beta/ose-deployer:v0.4.3.2
docker pull openshift3_beta/ose-sti-builder:v0.4.3.2
docker pull openshift3_beta/ose-docker-builder:v0.4.3.2
docker pull openshift3_beta/ose-pod:v0.4.3.2
docker pull openshift3_beta/ose-docker-registry:v0.4.3.2
docker pull openshift3_beta/sti-basicauthurl:latest


# Extra images for LABS
docker pull openshift3_beta/ruby-20-rhel7
docker pull openshift3_beta/mysql-55-rhel7
docker pull openshift/hello-openshift
docker pull openshift/ruby-20-centos7
