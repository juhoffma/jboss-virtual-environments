#!/usr/bin/env bash

FSWJAR=jboss-fsw-installer-6.0.0.GA-redhat-4.jar
VAGRANT_DIR=/vagrant

#if [ ! -e $1 ]
#then
# echo "Script param must be SwithYard install name (and hostname)"
# exit 255
#fi

SY=fsw


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
if [ -d /home/jboss/jboss-eap-6.1 ] || [ -d /home/jboss/${SY} ]
then
    echo "Target directory already exists. Please remove it before installing FSW again."
    exit 250
fi

echo "Install SY" 
java -jar /tmp/jboss-fsw-installer-6.0.0.GA-redhat-4.jar /vagrant/manifests/files/install-fsw.xml -variablefile /vagrant/manifests/files/install-fsw.xml.variables

if [ ! -e  /home/jboss/jboss-eap-6.1 ]
then
   echo "Installation went wrong!!!"
   exit 253
fi

echo "Renaming the EAP dir to honour name of SwithYard install"
mv /home/jboss/jboss-eap-6.1 /home/jboss/${SY}

echo "Binding JBoss EAP to ${SY} ip address"
`cat  /home/jboss/${SY}/bin/standalone.conf | grep "jboss.bind.address=" | grep -v "#"`
RET=$?   
if [ $RET != 0 ]
then
   echo "JAVA_OPTS=\"\$JAVA_OPTS -Djboss.bind.address=0.0.0.0 -Djboss.bind.address.management=0.0.0.0 -Djboss.bind.address.unsecure=0.0.0.0 \"" >> /home/jboss/${SY}/bin/standalone.conf
fi

#
# Change deployment targets for governance
#
sed -i -e 's/\/tmp\/.*\/jbossas7/\/home\/jboss\/fsw/g' /home/jboss/${SY}/standalone/configuration/dtgov.properties

#
# Install init script and register as a service
# 
if [ ! -e /etc/init.d/standalone ]
then
   cp /home/jboss/fsw/bin/init.d/jboss-as-standalone.sh /etc/init.d/standalone
   mkdir -p /etc/jboss-as
   cp /home/jboss/fsw/bin/init.d/jboss-as.conf /etc/jboss-as/
   # Set username
   `cat  /etc/jboss-as/jboss-as.conf | grep JBOSS_USER | grep -v #`
   RET=$?   
   if [ $RET != 0 ]
   then
      echo "JBOSS_USER=jboss" >> /etc/jboss-as/jboss-as.conf
   fi
   `cat  /etc/jboss-as/jboss-as.conf | grep STARTUP_WAIT | grep -v #`
   RET=$?   
   if [ $RET != 0 ]
   then
      echo "STARTUP_WAIT=180" >> /etc/jboss-as/jboss-as.conf
   fi
   `cat  /etc/jboss-as/jboss-as.conf | grep JBOSS_HOME | grep -v #`
   RET=$?   
   if [ $RET != 0 ]
   then
      echo "JBOSS_HOME=/home/jboss/fsw" >> /etc/jboss-as/jboss-as.conf
   fi
   chkconfig --add standalone 
   chkconfig --level 345 standalone on
fi

#rm /home/jboss/InstallationLog.txt
#rm /home/jboss/Install*.html

# After everything is done, fix owner
chown -R jboss:jboss /home/jboss/${SY}

#
# Start the server
#
service standalone start

#
# Wait until the server is started
#
sleep 10
{ tail -n +1 -f /home/jboss/${SY}/standalone/log/server.log & } | sed -n '/JBoss Red Hat JBoss Fuse Service Works 6/q'


#
# Install governance workflows
#
/home/jboss/${SY}/bin/s-ramp.sh -f /vagrant/manifests/files/s-ramp-workflows.commands
