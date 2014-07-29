#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
java -jar ${DIR}/jboss-fsw-installer-6.0.0.GA-redhat-4.jar ${DIR}/install-sy.xml -variablefile ${DIR}/install-sy.xml.variables
PATCH="BZ-1085860"
unzip -o ${DIR}/${PATCH}/fsw-6.0_1_2014-base.zip -d /home/jboss
# unzip -o ${DIR}/${PATCH}/fsw-6.0_1_2014-dtgov.zip -d /home/jboss
# unzip -o ${DIR}/${PATCH}/fsw-6.0_1_2014-rtgov-s.zip -d /home/jboss
# unzip -o ${DIR}/${PATCH}/fsw-6.0_1_2014-sramp.zip -d /home/jboss
unzip -o ${DIR}/${PATCH}/fsw-6.0_1_2014-switchyard.zip -d /home/jboss

###
# Customize configuration for Switchyard
#

#
# Fix hostnames
#
# sed -i -e 's/localhost/dtgov/g' ${_install_path}/jboss-eap-6.1/standalone/configuration/dtgov.properties 2> /dev/null
# sed -i -e 's/localhost/dtgov/g' ${_install_path}/jboss-eap-6.1/standalone/configuration/dtgov-ui.properties 2> /dev/null
# sed -i -e 's/localhost/dtgov/g' ${_install_path}/jboss-eap-6.1/standalone/configuration/sramp.properties 2> /dev/null
# sed -i -e 's/localhost/dtgov/g' ${_install_path}/jboss-eap-6.1/standalone/configuration/dtgov-ui.properties 2> /dev/null
# sed -i -e 's/localhost/rtgov/g' ${_install_path}/jboss-eap-6.1/standalone/configuration/overlord-rtgov.properties 2> /dev/null
# sed -i -e 's/localhost/rtgov/g' ${_install_path}/jboss-eap-6.1/standalone/configuration/gadget-server.properties 2> /dev/null
