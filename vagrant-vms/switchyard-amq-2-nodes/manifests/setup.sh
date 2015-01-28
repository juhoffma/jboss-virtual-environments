#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Import common functions
if [ ! -f ${DIR}/common_functions ]
then
   echo "${DIR}/common_functions does not exist. This script can not run"
   exit 255
else
   . ${DIR}/common_functions
   echo "common_functions loaded"
fi

_this=$1


##
# Installs additional packages
#
#
function install_additional_packages {
   echo "Installing additional packages (augeas, ...)"
   # TODO: Check for package being installed, otherwise execute yum and check for results. 
   yum -y install augeas libxslt
   rpm -ivh ${DIR}/installers/xmlstarlet-1.5.0-1.el6.rf.x86_64.rpm
}


function install_Oracle_JDK7 {
   local _completefile=$DIR/installers/jdk/${JDK_INSTALLER}
   if [ -z  ${JDK_INSTALL_PATH} ]
   then
      echo_nook "To install java you must also specify JDK_INSTALL_PATH environment variable for the install path"
      exit 255
   fi

   if [ ! -d ${JDK_INSTALL_PATH} ]
   then
      mkdir -p ${JDK_INSTALL_PATH} 2> /dev/null
      [ $? -ne 0 ] && exit_error "Impossible to create ${JDK_INSTALL_PATH}"
   fi 

   if [ ! -f $_completefile ]
   then
      echo_nook "Java installer binary not found in: $_completefile"
      exit 255
   else   
      echo_info "Installing java: $_filename"
      _linkname=$(tar -tvf $_completefile | head -1 | awk '{print $6'})
      tar -xvzf $_completefile -C ${JDK_INSTALL_PATH} 2>/dev/null
      [ $? -ne 0 ] && exit_error "Java installation error"
      
      echo_ok "Java installed succesfully"
      ln -s ${JDK_INSTALL_PATH}/$_linkname ${JDK_INSTALL_PATH}/java 2> /dev/null
      #[ $? -ne 0 ] && exit_error "Java installation error"

      echo_info "Link for ${JDK_INSTALL_PATH}/$_linkname created at ${JDK_INSTALL_PATH}/java"  
      echo "export JAVA_HOME=${JDK_INSTALL_PATH}/java" > /etc/profile.d/java.sh
      echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile.d/java.sh
      echo_info "Java profile created at /etc/profile.d/java.sh"
      # TODO: fix /etc/java/java.conf
      ## java ##
      /usr/sbin/alternatives --install /usr/bin/java java ${JDK_INSTALL_PATH}/java/jre/bin/java 200000
      /usr/sbin/alternatives --install /usr/bin/javaws javaws ${JDK_INSTALL_PATH}/java/jre/bin/javaws 200000
      #/usr/sbin/alternatives --install /usr/lib64/mozilla/plugins/libjavaplugin.so libjavaplugin.so.x86_64 ${JDK_INSTALL_PATH}/java/jre/lib/amd64/libnpjp2.so 200000
      /usr/sbin/alternatives --install /usr/bin/javac javac ${JDK_INSTALL_PATH}/java/bin/javac 200000
      /usr/sbin/alternatives --install /usr/bin/jar jar ${JDK_INSTALL_PATH}/java/bin/jar 200000
      # Source the file to have java
      . /etc/profile.d/java.sh
   fi   
}


# Creates encoded password for management realm
function encrypt_admin_password { 
   local _user=$SY_USER
   local _password=$SY_PASSWD
   
   MI_CLASSPATH="${DIR}/files/fsw/encrypt/jboss-client.jar:${DIR}/files/fsw/encrypt/jbosssx-3.0.0.Final.jar:${DIR}/files/fsw/encrypt/:"

   echo "$(java -cp $MI_CLASSPATH EncryptPassword $_user $_password)"
}

#
# Installs switchyard binaries and registers service
#
# Env variables needed:
#   IP_SVC
#   IP_MGMT
#   OS_USER
#   OS_GROUP
#   SY_INSTALLER
#   [SY_ROLLUP]
#   SY_INSTALL_PATH
#   SY_INSTANCE_NAME
#   SY_USER
#   SY_PASSWD
#   SY_PROFILE
function install_switchyard {

   # Validate there is the binary file
   [ ! -f ${DIR}/installers/fsw/${SY_INSTALLER} ] && echo_error "SwitchYard installer missing from ${DIR}/installers/fsw/${SY_INSTALLER}" && exit 1

   # Validate that the target installation does not already exist
   if [ -d ${SY_INSTALL_PATH}/jboss-eap-6.1 ] || [ -d ${SY_INSTALL_PATH}/${SY_INSTANCE_NAME} ]
   then
      echo_nook "Target directory already exists. Please remove it before installing again."
      exit 250
   else
      echo_info "SwitchYard will be installed in ${SY_INSTALL_PATH}"  
   fi

   local _encrypted_admin=$(encrypt_admin_password)
   
   echo "Password for admin encrypted ($_encrypted_admin)"

   # TODO: Do all the sed into tmp files, not the real ones.
   cp -f ${DIR}/files/fsw/install-sy.xml /tmp/install-sy.xml
   cp -f ${DIR}/files/fsw/install-sy.xml.variables /tmp/install-sy.xml.variables

   # Before we install, we need to modify the install.xml to have the correct install path
   sed -i -e "s/<installpath>.*<\/installpath>/<installpath>$(echo ${SY_INSTALL_PATH} | sed -e 's/[\/&]/\\&/g')<\/installpath>/g" /tmp/install-sy.xml
   # If admin password is set, change it
   sed -i -e "s/adminPassword\" value=\".*\"/adminPassword\" value=\"$(echo ${_encrypted_admin} | sed -e 's/[\/&]/\\&/g')\"/g" /tmp/install-sy.xml
   sed -i -e "s/password=.*/password=$(echo ${SY_PASSWD} | sed -e 's/[\/&]/\\&/g')/g" /tmp/install-sy.xml.variables
   sed -i -e "s/storepass=.*/storepass=$(echo ${SY_PASSWD} | sed -e 's/[\/&]/\\&/g')/g" /tmp/install-sy.xml.variables
   sed -i -e "s/keystorepwd=.*/keystorepwd=$(echo ${SY_PASSWD} | sed -e 's/[\/&]/\\&/g')/g" /tmp/install-sy.xml.variables

   echo_info "Install ${PRODUCT_NAME}" 
   # Check for configuration files
   [ ! -f /tmp/install-sy.xml ] && echo_error "Configuration file (/tmp/install-sy.xml) not properly setup" && exit 1
   [ ! -f /tmp/install-sy.xml.variables ] && echo_error "Configuration file (/tmp/install-sy.xml.variables) not properly setup" && exit 1
   java -jar ${DIR}/installers/fsw/${SY_INSTALLER} /tmp/install-sy.xml -variablefile /tmp/install-sy.xml.variables

   if [ ! -e  ${SY_INSTALL_PATH}/jboss-eap-6.1 ]
   then
      echo_nook "Installation went wrong!!!"
      exit 253
   else
      echo "SwitchYard installed successsfuly"
   fi

   # Install RollupPatch
   local _rollupfile="${DIR}/installers/fsw/${SY_ROLLUP}.zip"
   if [ -f "${rollupfile}" ]
   then
      echo "Installing ${SY_ROLLUP}"
      mkdir -p /tmp/${SYROLLUP}
      # Only extract base and switchyard patches
      unzip -oj ${_rollupfile} *base*.zip *switchyard*.zip -d /tmp/${SY_ROLLUP}
      for i in `ls -v /tmp/${SY_ROLLUP}/*.zip`
      do
        unzip -o $i -d ${SY_INSTALL_PATH}
      done
      rm -rf /tmp/${SY_ROLLUP}
   fi 

   # INSTALL One-off-patches
   if [ -f "${DIR}/installers/fsw/patches/patch.sh" ]
   then
      echo "Installing One off patches"
      . ${DIR}/installers/fsw/patches/patch.sh ${SY_INSTALL_PATH}/${SY_INSTANCE_NAME}
   fi 
   
   echo_info "Renaming the EAP dir to ${SY_INSTANCE_NAME} to honour name of SwitchYard install"
   mv ${SY_INSTALL_PATH}/jboss-eap-6.1 ${SY_INSTALL_PATH}/${SY_INSTANCE_NAME}
  
   # Removing data dir to rename without issues
   # TODO: If installing with the default h2 database, this directory can not be removed.
#   rm -rf ${SY_INSTALL_PATH}/${SY_INSTANCE_NAME}/standalone/data
   rm -rf ${SY_INSTALL_PATH}/${SY_INSTANCE_NAME}/standalone/tmp
   # Sed a change for logging configuration
   sed -i -e "s/jboss-eap-6.1/${SY_INSTANCE_NAME}/g" ${SY_INSTALL_PATH}/${SY_INSTANCE_NAME}/standalone/configuration/logging.properties
   
   # After everything is done, fix owner
   echo_info "Setting permissions to ${SY_INSTALL_PATH}/${SY_INSTANCE_NAME} for user ${OS_USER}:${OS_GROUP}"
   chown -R ${OS_USER}:${OS_GROUP} ${SY_INSTALL_PATH}/${SY_INSTANCE_NAME}
   
   # Delete installation files
   rm ${SY_INSTALL_PATH}/InstallationLog.txt
   #rm ${SY_INSTALL_PATH}/Install*.html

   echo_info "Set bind address for standalone configuration in ${SY_INSTALL_PATH}/${SY_INSTANCE_NAME}"
   # TODO: Replace every token, for every config alternative
   # See: https://docs.jboss.org/author/display/AS71/Command+line+parameters
   `cat  ${SY_INSTALL_PATH}/${SY_INSTANCE_NAME}/bin/standalone.conf | grep "jboss.bind.address=" | grep -v "#"`
   RET=$?   
   if [ $RET != 0 ]
   then
      if [ ! -z ${SY_BIND_ADDR} ]
      then
         echo "JAVA_OPTS=\"\$JAVA_OPTS -Djboss.bind.address=${SY_BIND_ADDR} -Djboss.bind.address.management=${SY_BIND_ADDR} \"" >> ${SY_INSTALL_PATH}/${SY_INSTANCE_NAME}/bin/standalone.conf
      else
         echo "JAVA_OPTS=\"\$JAVA_OPTS -Djboss.bind.address=${IP_SVC} -Djboss.bind.address.management=${IP_MGMT} \"" >> ${SY_INSTALL_PATH}/${SY_INSTANCE_NAME}/bin/standalone.conf
      fi
   fi

   # Fix logging problem in ha profiles
   echo "Fixing logging for standalone-full-ha.xml profile"
   sed -i "/$(escapepattern urn:jboss:domain:logging:1.2)/r ${DIR}/files/fsw/logging-fix.xml"  ${SY_INSTALL_PATH}/${SY_INSTANCE_NAME}/standalone/configuration/standalone-full-ha.xml
   sed -i "/<handler name=\"FILE\"\/>/r ${DIR}/files/fsw/logging-fix2.xml"  ${SY_INSTALL_PATH}/${SY_INSTANCE_NAME}/standalone/configuration/standalone-full-ha.xml

   #
   # Install init script and register as a service

   if [ ! -e /etc/init.d/${SY_INSTANCE_NAME} ]
   then
       cp ${DIR}/files/fsw/jboss-instance.sh /etc/init.d/${SY_INSTANCE_NAME}
       chmod 755 /etc/init.d/${SY_INSTANCE_NAME}
       mkdir -p /etc/jboss-as
       cp ${DIR}/files/fsw/jboss-instance.conf /etc/jboss-as/${SY_INSTANCE_NAME}.conf
       if [ -e /sbin/chkconfig ]
       then
         /sbin/chkconfig --add ${SY_INSTANCE_NAME} 
         /sbin/chkconfig --level 345 ${SY_INSTANCE_NAME} on
       else  
         # TODO: If there is no chkconfig, register the service the old way
         echo "TODO: Creating links"
         
       fi
   fi
   
   # Sed configuration
   sed -i -e "s/JBOSS_HOME=.*/JBOSS_HOME=$(echo ${SY_INSTALL_PATH}/${SY_INSTANCE_NAME} | sed -e 's/[\/&]/\\&/g')/g" /etc/jboss-as/${SY_INSTANCE_NAME}.conf
   sed -i -e "s/JBOSS_USER=.*/JBOSS_USER=$(echo ${OS_USER} | sed -e 's/[\/&]/\\&/g')/g" /etc/jboss-as/${SY_INSTANCE_NAME}.conf
   sed -i -e "s/JBOSS_CONFIG=.*/JBOSS_CONFIG=$(echo ${SY_PROFILE} | sed -e 's/[\/&]/\\&/g')/g" /etc/jboss-as/${SY_INSTANCE_NAME}.conf
}


# Installs AMQ binaries and registers service
#
# Arguments
#   $1: role
#
# Env variables needed:
#   OS_USER
#   OS_GROUP
#   AMQ_INSTALLER
#   AMQ_INSTALL_PATH
#   AMQ_USER
#   AMQ_PASSWD
function install_amq {
    local _role=$1
    local _instance_name=${AMQ_INSTANCE_NAME}-${_role}

   # Validate that the target installation does not already exist
   if [ -d ${AMQ_INSTALL_PATH}/jboss-a-mq-6.1.0.redhat-379 ] || [ -d ${AMQ_INSTALL_PATH}/${_instance_name} ]
   then
      echo_nook "Target directory already exists. Please remove it before installing again."
      exit 250
   else
      echo_info "AMQ will be installed in ${AMQ_INSTALL_PATH}"  
   fi

   echo_info "Install AMQ" 
   [ ! -f ${DIR}/installers/amq/${AMQ_INSTALLER} ] && echo_error "No AMQ Binary for installation found here: ${DIR}/installers/amq/${AMQ_INSTALLER}" && exit 1
   unzip -o ${DIR}/installers/amq/${AMQ_INSTALLER} -d ${AMQ_INSTALL_PATH}

   if [ ! -e  ${AMQ_INSTALL_PATH}/jboss-a-mq-6.1.0.redhat-379 ]
   then
      echo_nook "Installation went wrong!!!"
      exit 253
   else
      echo "AMQ installed successsfuly"
   fi
   
   echo_info "Renaming the Product dir to ${_instance_name} to honour name of AMQ install"
   mv ${AMQ_INSTALL_PATH}/jboss-a-mq-6.1.0.redhat-379 ${AMQ_INSTALL_PATH}/${_instance_name}
  
   # Enable admin user
   echo " " >> ${AMQ_INSTALL_PATH}/${_instance_name}/etc/users.properties
   echo "${AMQ_USER}=${AMQ_PASSWD},admin" >> ${AMQ_INSTALL_PATH}/${_instance_name}/etc/users.properties

   # Generate the wrapper
   ${AMQ_INSTALL_PATH}/${_instance_name}/bin/start
   ${AMQ_INSTALL_PATH}/${_instance_name}/bin/client -u ${AMQ_USER} -p ${AMQ_PASSWD} -r 10 -d 5 "features:install wrapper"
   ${AMQ_INSTALL_PATH}/${_instance_name}/bin/client -u ${AMQ_USER} -p ${AMQ_PASSWD} -r 10 "wrapper:install -n ${_instance_name} -d ${_instance_name} -D ${_instance_name}"
   ${AMQ_INSTALL_PATH}/${_instance_name}/bin/stop

   # TODO: Check that everything went ok and install then
   [ ! -f ${AMQ_INSTALL_PATH}/${_instance_name}/bin/${_instance_name}-service ] && echo_error "Error installing AMQ ${_instance_name} wrapper" && exit 1
   [ -L /etc/init.d/${_instance_name} ] && rm /etc/init.d/${_instance_name}
   ln -s ${AMQ_INSTALL_PATH}/${_instance_name}/bin/${_instance_name}-service /etc/init.d/${_instance_name}
   chkconfig ${_instance_name} --add
   chkconfig ${_instance_name} on
   # Set the service to start with appropriate user
   sed -i -e "s/#RUN_AS_USER=.*/RUN_AS_USER=$(echo ${OS_USER} | sed -e 's/[\/&]/\\&/g')/g" ${AMQ_INSTALL_PATH}/${_instance_name}/bin/${_instance_name}-service

   # Remove temporary files created with user root
   rm -rf ${AMQ_INSTALL_PATH}/${_instance_name}/data

   # Copy activemq.xml template file to the appropriate destination and modify it accordingly
   cp -f ${DIR}/customizations/amq/activemq-TEMPLATE.xml ${AMQ_INSTALL_PATH}/${_instance_name}/etc/activemq.xml
   # USER, PASSWORD, PORT, TRANSPORT_URI, LEVELDB_PATH
   local _amq_uri="none"
   local _level_db_path="temp"
   local _port=0 
   if [[ "${_role}" == "master" ]]
   then
      if [[ "${_this}" == "fsw01" ]]
      then
         _level_db_path="/opt/amq/data/fsw01"
         _amq_uri="masterslave:(tcp://fsw02-repl:61616,tcp://localhost:61617)"
      else
         _level_db_path="/opt/amq/data/fsw02"
         _amq_uri="masterslave:(tcp://fsw01-repl:61616,tcp://localhost:61617)"
      fi
      _level_db_path=
      _port=${AMQ_SLAVE_PORT}
   else # SLAVE
      if [[ "${_this}" == "fsw01" ]]
      then
         _level_db_path="/opt/amq/data/fsw02"
         _amq_uri="masterslave:(tcp://localhost:61616,tcp://fsw02-repl:61617)"
      else
         _level_db_path="/opt/amq/data/fsw01"
         _amq_uri="masterslave:(tcp://localhost:61616,tcp://fsw01-repl:61617)"
      fi
      _port=${AMQ_MASTER_PORT}
   fi
   echo "Updating ${AMQ_INSTALL_PATH}/${_instance_name}/etc/activemq.xml configuration"   
   sed -i -e "s/#PORT#/${_port}/g" ${AMQ_INSTALL_PATH}/${_instance_name}/etc/activemq.xml
   sed -i -e "s/#USER#/$(echo ${AMQ_USER} | sed -e 's/[\/&]/\\&/g')/g" ${AMQ_INSTALL_PATH}/${_instance_name}/etc/activemq.xml
   sed -i -e "s/#PASSWORD#/$(echo ${AMQ_PASSWD} | sed -e 's/[\/&]/\\&/g')/g" ${AMQ_INSTALL_PATH}/${_instance_name}/etc/activemq.xml
   sed -i -e "s/#TRANSPORT_URI#/$(echo ${_amq_uri} | sed -e 's/[\/&]/\\&/g')/g" ${AMQ_INSTALL_PATH}/${_instance_name}/etc/activemq.xml
   # /opt/amq/data/fsw01
   sed -i -e "s/#LEVELDB_PATH#/$(echo ${_leveldb_path} | sed -e 's/[\/&]/\\&/g')/g" ${AMQ_INSTALL_PATH}/${_instance_name}/etc/activemq.xml

   # After everything is done, fix owner
   echo_info "Setting permissions to ${AMQ_INSTALL_PATH}/${_instance_name} for user ${OS_USER}:${OS_USER}"
   chown -R ${OS_USER}:${OS_USER} ${AMQ_INSTALL_PATH}/${_instance_name}
}

#
# Install JBoss ActiveMQ Resource Adapter into SwitchYard installation
#
#
function install_amq_rar {
   # Install amq RAR from the master install
   [ ! -f ${AMQ_INSTALL_PATH}/${AMQ_INSTANCE_NAME}-master/extras/${APACHEAMQ_VERSION}-bin.zip ] && echo_error "There is no ActiveMQ adapter available here: ${AMQ_INSTALL_PATH}/${AMQ_INSTANCE_NAME}-master/extras/${APACHEAMQ_VERSION}-bin.zip" && exit 1
   unzip -oj ${AMQ_INSTALL_PATH}/${AMQ_INSTANCE_NAME}-master/extras/${APACHEAMQ_VERSION}-bin.zip ${APACHEAMQ_VERSION}/lib/optional/${AMQRAR_FILENAME} -d ${SY_INSTALL_PATH}/${SY_INSTANCE_NAME}/standalone/deployments/
   mv ${SY_INSTALL_PATH}/${SY_INSTANCE_NAME}/standalone/deployments/${AMQRAR_FILENAME} ${SY_INSTALL_PATH}/${SY_INSTANCE_NAME}/standalone/deployments/activemq-rar.rar 

   # Copy customizations file, and sed variables
   cp -f ${DIR}/customizations/amq/resourceadapters.xml /tmp/resourceadapters.xml
   if [[ "${_this}" == "fsw01" ]]
   then
      _other="fsw02-repl"
   else
      _other="fsw01-repl"
   fi
   sed -i -e "s/#OTHER#/${_other}/g" /tmp/resourceadapters.xml
   sed -i -e "s/#AMQ_PASSWD#/${AMQ_PASSWD}/g" /tmp/resourceadapters.xml
   sed -i -e "s/#AMQ_USER#/${AMQ_USER}/g" /tmp/resourceadapters.xml

   # Insert snippet into SY Configuration file
   sed -e '/resource-adapters/ {' -e 'r /tmp/resourceadapters.xml' -e 'd' -e '}' -i ${SY_INSTALL_PATH}/${SY_INSTANCE_NAME}/standalone/configuration/standalone-full-ha.xml

   # Update the mdbs to use AMQ
   sed -i -e 's/resource-adapter-name="hornetq-ra"/resource-adapter-name="org.apache.activemq.ra"/g' ${SY_INSTALL_PATH}/${SY_INSTANCE_NAME}/standalone/configuration/standalone-full-ha.xml

   # Change permissions
   chown -R ${OS_USER}:${OS_USER} ${SY_INSTALL_PATH}/${SY_INSTANCE_NAME}
}


# If this script is not run with sudo or su fail
fail_if_not_root

# Source configuration
. ${DIR}/custom.properties

# Install required packages
# TODO: DONE
 install_additional_packages

# Setting up the ulimits
# TODO: DONE
 setup_ulimits 8192

# Create hostnames in /etc/hosts
# TODO: DONE
add_hostname ${_this} $(eval "echo \$$(echo ${_this}_IP_SVC)")
for _name in fsw01 fsw02
do
   add_hostname ${_name} $(eval "echo \$$(echo ${_name^^}_IP_SVC)")
   add_hostname ${_name} $(eval "echo \$$(echo ${_name^^}_IP_MGMT)")
   add_hostname ${_name} $(eval "echo \$$(echo ${_name^^}_IP_REPL)")
done

# Change hostname
# TODO: DONE
set_hostname ${_this}

# Create OS users and groups
# TODO: DONE
add_group $OS_GROUP
add_user $OS_USER $OS_GROUP

# Install Oracle JDK
# TODO: DONE
install_Oracle_JDK7

# Install SwitchYard
# TODO: DONE
install_switchyard

# Install AMQ Master
install_amq "master"

# Install AMQ Slave
# TODO: DONE
install_amq "slave"

# Install AMQ RAR
# TODO: DONE
install_amq_rar

# Customize SY
# TODO

# Start services
# TODO: DONE
service ${AMQ_INSTANCE_NAME}-master start
service ${AMQ_INSTANCE_NAME}-slave start
service ${SY_INSTANCE_NAME} start

echo "Done"