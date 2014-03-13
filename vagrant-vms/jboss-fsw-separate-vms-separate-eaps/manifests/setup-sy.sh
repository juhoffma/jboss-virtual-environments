#!/usr/bin/env bash

FSWJAR=jboss-fsw-installer-6.0.0.GA-redhat-4.jar
VAGRANT_DIR=/vagrant

PRODUCT_NAME=SwitchYard
PRODUCT_SCRIPTNAME=sy

if [ ! -e $1 ]
then
 echo "Script param must be ${PRODUCT_NAME} install name (and hostname)"
 exit 255
fi

EAP_INSTANCE_DIRNAME=${PRODUCT_SCRIPTNAME}

# We get the ip from /etc/hosts. Hostname will have same name as EAP instance dir
echo "cat /etc/hosts | grep ${EAP_INSTANCE_DIRNAME} | cut -f 1"
INSTANCE_IP=`cat /etc/hosts | grep ${EAP_INSTANCE_DIRNAME} | cut -f 1`


if [[ "${INSTANCE_IP}" == "" ]]
then
   echo "File /etc/hosts not correctly set. Can't find ip for ${EAP_INSTANCE_DIRNAME} hostname"
   exit 251
else
   echo "${PRODUCT_NAME} will be installed and bound to ${INSTANCE_IP}"   
fi   

echo "Lets change to tmp dir to make all the install process from here"
cd /tmp

if [ -f $FSWJAR ];
then
	echo "File $FSWJAR exists"
else
	echo "File $FSWJAR does not exists. Please download it from acces portal and put it in files folder"
	exit 255
fi

# Validate that the target installation does not already exist
if [ -d /home/jboss/jboss-eap-6.1 ] || [ -d /home/jboss/${EAP_INSTANCE_DIRNAME} ]
then
    echo "Target directory already exists. Please remove it before installing FSW again."
    exit 250
fi

echo "Install ${PRODUCT_NAME}" 
java -jar /tmp/jboss-fsw-installer-6.0.0.GA-redhat-4.jar /vagrant/manifests/files/install-${PRODUCT_SCRIPTNAME}.xml -variablefile /vagrant/manifests/files/install-${PRODUCT_SCRIPTNAME}.xml.variables

if [ ! -e  /home/jboss/jboss-eap-6.1 ]
then
   echo "Installation went wrong!!!"
   exit 253
fi

echo "Renaming the EAP dir to honour name of ${PRODUCT_NAME} install"
mv /home/jboss/jboss-eap-6.1 /home/jboss/${EAP_INSTANCE_DIRNAME}

echo "Binding JBoss EAP to ${PRODUCT_SCRIPTNAME} ip address"
`cat  /home/jboss/${EAP_INSTANCE_DIRNAME}/bin/standalone.conf | grep "jboss.bind.address=" | grep -v "#"`
RET=$?   
if [ $RET != 0 ]
then
   echo "JAVA_OPTS=\"\$JAVA_OPTS -Djboss.bind.address=${INSTANCE_IP} -Djboss.bind.address.management=${INSTANCE_IP} -Djboss.bind.address.unsecure=${INSTANCE_IP} \"" >> /home/jboss/${EAP_INSTANCE_DIRNAME}/bin/standalone.conf
fi

#
# Fix hostnames
#
sed -i -e 's/localhost/dtgov/g' /home/jboss/${EAP_INSTANCE_DIRNAME}/standalone/configuration/dtgov.properties 2> /dev/null
sed -i -e 's/localhost/dtgov/g' /home/jboss/${EAP_INSTANCE_DIRNAME}/standalone/configuration/dtgov-ui.properties 2> /dev/null
sed -i -e 's/localhost/dtgov/g' /home/jboss/${EAP_INSTANCE_DIRNAME}/standalone/configuration/sramp.properties 2> /dev/null
sed -i -e 's/localhost/dtgov/g' /home/jboss/${EAP_INSTANCE_DIRNAME}/standalone/configuration/dtgov-ui.properties 2> /dev/null
sed -i -e 's/localhost/rtgov/g' /home/jboss/${EAP_INSTANCE_DIRNAME}/standalone/configuration/overlord-rtgov.properties 2> /dev/null
sed -i -e 's/localhost/rtgov/g' /home/jboss/${EAP_INSTANCE_DIRNAME}/standalone/configuration/gadget-server.properties 2> /dev/null

#
# Install init script and register as a service
# 
if [ ! -e /etc/init.d/${EAP_INSTANCE_DIRNAME} ]
then
    cp /vagrant/manifests/files/jboss-instance.sh /etc/init.d/${EAP_INSTANCE_DIRNAME}
    chmod 755 /etc/init.d/${EAP_INSTANCE_DIRNAME}
    mkdir -p /etc/jboss-as
    cp /vagrant/manifests/files/${EAP_INSTANCE_DIRNAME}.conf /etc/jboss-as/
    chkconfig --add ${EAP_INSTANCE_DIRNAME} 
    chkconfig --level 345 ${EAP_INSTANCE_DIRNAME} on
fi

rm /home/jboss/InstallationLog.txt
#rm /home/jboss/Install*.html

# After everything is done, fix owner
chown -R jboss:jboss /home/jboss/${EAP_INSTANCE_DIRNAME}

#
# Start the server
#
service ${EAP_INSTANCE_DIRNAME} start

#
# Wait until the server is started
#
sleep 5
timeout 120 grep -q 'started in' <(tail -f /home/jboss/${EAP_INSTANCE_DIRNAME}/standalone/log/server.log)


#
# Install governance workflows
#
#/home/jboss/${EAP_INSTANCE_DIRNAME}/bin/s-ramp.sh -f /vagrant/manifests/files/s-ramp-workflows.commands
