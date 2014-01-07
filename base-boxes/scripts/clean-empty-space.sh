#!/bin/bash		

# Saves ~25M
yum -y remove kernel-devel

# Cleanup other files we do not need
yum -y groupremove "Dialup Networking Support" Editors "Printing Support" "Additional Development" "E-mail server"

# Clean cache
yum clean all

# Clean out all of the caching dirs
rm -rf /var/cache/* /usr/share/doc/*

# Clean up unused disk space so compressed image is smaller.
cat /dev/zero > /tmp/zero.fill
rm /tmp/zero.fill
