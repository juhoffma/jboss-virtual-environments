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
RET=`cat  /home/jboss/${SY}/bin/standalone.conf | grep "jboss.bind.address=" | grep -v "#"`
if [[ "$RET" == "" ]]
then
   echo "JAVA_OPTS=\"\$JAVA_OPTS -Djboss.bind.address=0.0.0.0 -Djboss.bind.address.management=0.0.0.0 -Djboss.bind.address.unsecure=0.0.0.0 \"" >> /home/jboss/${SY}/bin/standalone.conf
fi

#
# Change deployment targets for governance
#
sed -i -e 's/\/tmp\/.*\/jbossas7/\/home\/jboss\/fsw/g' /home/jboss/${SY}/standalone/configuration/dtgov.properties 2> /dev/null

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

echo "Strarting ${SY} instance"
#
# Start the server
#
service standalone start

#
# Wait until the server is started
#
echo "Will wait until started"
sleep 10
{ tail -n +1 -f /home/jboss/${SY}/standalone/log/server.log & } | sed -n '/started in/q' 2> /dev/null

echo "Started"

#
# Install governance workflows
#
echo "Deploying governance workflows"
/home/jboss/${SY}/bin/s-ramp.sh -f /vagrant/manifests/files/s-ramp-workflows.commands
echo "Governance workflowsi deployed"


JBDS_INSTALLER=/vagrant/manifests/files/jbdevstudio-product-universal-7.1.0.GA-v20131208-0703-B592.jar
#
# Install JBDS & Integration Stack plugins
#
if [ -e ${JBDS_INSTALLER} ]
then
   echo "Installing JBDS and Integration Stack plugins"
   # Install JBDS
   java -jar${JBDS_INSTALLER} /vagrant/manifests/files/install-jbds.xml 
   # Install Integration Stack
   /home/jboss/jbdevstudio/jbdevstudio -nosplash -application org.eclipse.equinox.p2.director -repository https://devstudio.jboss.com/updates/7.0/,https://devstudio.jboss.com/updates/7.0/integration-stack/ -installIU org.eclipse.bpmn2.feature.feature.group,org.eclipse.bpmn2.modeler.feature.feature.group,org.eclipse.bpmn2.modeler.jboss.runtime.feature.feature.group,org.fusesource.ide.camel.editor.feature.feature.group,org.fusesource.ide.runtimes.feature.feature.group,org.fusesource.ide.server.extensions.feature.feature.group,org.guvnor.tools.feature.feature.group,org.jboss.tools.bpel.feature.feature.group,org.jboss.tools.esb.feature.feature.group,org.jboss.tools.jbpm.common.feature.feature.group,org.jboss.tools.jbpm.convert.feature.feature.group,org.jboss.tools.jbpm3.feature.feature.group,org.jboss.tools.runtime.drools.detector.feature.feature.group,org.jboss.tools.runtime.esb.detector.feature.feature.group,org.jboss.tools.runtime.jbpm.detector.feature.feature.group,org.jbpm.eclipse.feature.feature.group,org.switchyard.tools.bpel.feature.feature.group,org.switchyard.tools.bpmn2.feature.feature.group,org.switchyard.tools.feature.feature.group
fi
