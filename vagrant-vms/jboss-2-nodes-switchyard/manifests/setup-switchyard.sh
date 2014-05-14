#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Import common functions
if [ ! -f ${DIR}/common_functions ]
then
   echo "${DIR}/common_functions does not exist. This script can not run"
   exit 255
else
   . ${DIR}/common_functions
fi

function sedeasy {
  echo "sed -i \"s/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $2 | sed -e 's/[\/&]/\\&/g')/g\" $3"
}

: ${FSWJAR:="jboss-fsw-installer-6.0.0.GA-redhat-4.jar"}
: ${PRODUCT_NAME:="SwitchYard"}
: ${PRODUCT_SCRIPTNAME:="sy"}
: ${FILES_DIR:="/vagrant/manifests/files"}
: ${INSTALLER:="${FILES_DIR}/${FSWJAR}"}

: ${DEFAULT_USER:="jboss"}
: ${DEFAULT_BIND:="0.0.0.0"}
: ${DEFAULT_DIR:="/opt"}

usage() {
   # TODO: Explain how it works
	echo "Usage: "
	echo "       $0 -i instance_name [-b bind_address] [-u user] [-i install_dir] [-?]"
	echo ""
	echo ""
	exit 250
}

#
# Checking pre requisites for installing SwitchYard
#
function check_pre_req {
   if [ ! -d $FILES_DIR ]
   then
	   echo_nook "$FILES_DIR does not exists."
	   exit 255
   fi
   if [ -f $INSTALLER ]
   then
	   echo_info "File $INSTALLER exists"
   else
	   echo_nook "File $INSTALLER does not exists. Please download it from acces portal and put it in files folder"
	   exit 255
   fi
}


# Installs switchyard binaries
# 
# Arguments:
#   $1: path
#   $2: user
function install_switchyard {
   local _instance_name=$_GLOBAL_INSTANCE
   local _install_path=$_GLOBAL_DIR
   local _user=$_GLOBAL_USER
 

   # Validate that the target installation does not already exist
   if [ -d ${_install_path}/jboss-eap-6.1 ] || [ -d ${_install_path}/${_instance_name} ]
   then
      echo_nook "Target directory already exists. Please remove it before installing again."
      exit 250
   else
      echo_info "${PRODUCT_NAME} will be installed in ${_install_path}"  
   fi

   # Before we install, we need to modify the install.xml to have the correct install path
   sed -i -e "s/<installpath>.*<\/installpath>/<installpath>$(echo ${_install_path} | sed -e 's/[\/&]/\\&/g')<\/installpath>/g" ${FILES_DIR}/install-${PRODUCT_SCRIPTNAME}.xml

   echo_info "Install ${PRODUCT_NAME}" 
   java -jar ${INSTALLER} ${FILES_DIR}/install-${PRODUCT_SCRIPTNAME}.xml -variablefile ${FILES_DIR}/install-${PRODUCT_SCRIPTNAME}.xml.variables

   if [ ! -e  ${_install_path}/jboss-eap-6.1 ]
   then
      echo_nook "Installation went wrong!!!"
      exit 253
   fi

   #
   # Fix hostnames
   #
   # sed -i -e 's/localhost/dtgov/g' ${_install_path}/jboss-eap-6.1/standalone/configuration/dtgov.properties 2> /dev/null
   # sed -i -e 's/localhost/dtgov/g' ${_install_path}/jboss-eap-6.1/standalone/configuration/dtgov-ui.properties 2> /dev/null
   # sed -i -e 's/localhost/dtgov/g' ${_install_path}/jboss-eap-6.1/standalone/configuration/sramp.properties 2> /dev/null
   # sed -i -e 's/localhost/dtgov/g' ${_install_path}/jboss-eap-6.1/standalone/configuration/dtgov-ui.properties 2> /dev/null
   # sed -i -e 's/localhost/rtgov/g' ${_install_path}/jboss-eap-6.1/standalone/configuration/overlord-rtgov.properties 2> /dev/null
   # sed -i -e 's/localhost/rtgov/g' ${_install_path}/jboss-eap-6.1/standalone/configuration/gadget-server.properties 2> /dev/null

   echo_info "Renaming the EAP dir to ${_instance_name} to honour name of ${PRODUCT_NAME} install"
   mv ${_install_path}/jboss-eap-6.1 ${_install_path}/${_instance_name}
  
   # After everything is done, fix owner
   echo_info "Setting permissions to ${_install_path}/${_instance_name} for user ${_user}"
   chown -R $_user:$_user ${_install_path}/${_instance_name}
   
   # Delete installation files
   rm ${_install_path}/InstallationLog.txt
   #rm ${_install_path}/Install*.html

   set_jboss_bind_address "standalone"
      
   # As a return it will output the install path
   echo "${_install_path}/${_instance_name}"
}


#
#
#  Arguments:
#     $1: install dir
#     $2: configuration
function set_jboss_bind_address {
   local _config=$1
   local _install_dir=$_GLOBAL_DIR
   local _instance_name=$_GLOBAL_INSTANCE
   local _bind_addr=$_GLOBAL_BIND
  

   echo_info "Set bind address for $_config configuration in $_install_dir/$_instance_name"

   `cat  $_install_dir/$_instance_name/bin/${_config}.conf | grep "jboss.bind.address=" | grep -v "#"`
   RET=$?   
   if [ $RET != 0 ]
   then
      echo "JAVA_OPTS=\"\$JAVA_OPTS -Djboss.bind.address=${_bind_addr} -Djboss.bind.address.management=${_bind_addr} -Djboss.bind.address.unsecure=${_bind_addr} \"" >> ${_install_dir}/${_instance_name}/bin/${_config}.conf
   fi
}


#
# Install init script and register as a service
# 
# Arguments:
#   $1: user
#   $2: instance_name
function register_service {
   local _install_dir=$_GLOBAL_DIR
   local _user=$_GLOBAL_USER
   local _instance_name=$_GLOBAL_INSTANCE

   if [ ! -e /etc/init.d/${_instance_name} ]
   then
       cp ${FILES_DIR}/jboss-instance.sh /etc/init.d/${_instance_name}
       chmod 755 /etc/init.d/${_instance_name}
       mkdir -p /etc/jboss-as
       cp ${FILES_DIR}/jboss-instance.conf /etc/jboss-as/${_instance_name}.conf
       chkconfig --add ${_instance_name} 
       chkconfig --level 345 ${_instance_name} on
   fi
   
   # Sed configuration
   sed -i -e "s/JBOSS_HOME=.*/JBOSS_HOME=$(echo ${_install_dir}/${_instance_name} | sed -e 's/[\/&]/\\&/g')/g" /etc/jboss-as/${_instance_name}.conf
   sed -i -e "s/JBOSS_USER=.*/JBOSS_USER=$(echo ${_user} | sed -e 's/[\/&]/\\&/g')/g" /etc/jboss-as/${_instance_name}.conf
}


#
# Start the server
function start_service_and_wait {
   local _install_dir=$_GLOBAL_DIR
   local _instance_name=$_GLOBAL_INSTANCE

   service ${_instance_name} start
   #
   # Wait until the server is started
   #
   sleep 5
   timeout 120 grep -q 'started in' <(tail -f ${_install_dir}/${_instance_name}/standalone/log/server.log)
}


#
# Parses command line arguments for script and check required params
#
function parse_options() {
   local _configured=0
   
   while getopts "i:b:u:d:" opt "$@"; do
     case $opt in
       i)
         _GLOBAL_INSTANCE=$OPTARG
         _configured=1
         ;;
       b)
         _GLOBAL_BIND=$OPTARG
         ;;
       u)
         _GLOBAL_USER=$OPTARG
         ;;
       d)
         _GLOBAL_DIR=$OPTARG
         ;;
       ?)
         usage
         ;;
       \?)
         echo "Invalid option: -$OPTARG" >&2
         ;;
      esac
   done
   if [ ${_configured} -eq 0 ]; then
      echo "Switchyard installation not properly configured"
      usage
   else
      # Set the defaults
      if [[ "$_GLOBAL_USER" == "" ]] 
      then 
         _GLOBAL_USER=$_DEFAULT_USER
      fi
      if [[ "$_GLOBAL_BIND" == "" ]]
      then
         _GLOBAL_BIND=$_DEFAULT_BIND
      fi
      if [[ "$_GLOBAL_DIR" == "" ]]
      then   
         _GLOBAL_DIR=$_DEFAULT_DIR
      fi
      echo "Configuration ready"   
      echo "Environment: ${_GLOBAL_INSTANCE}"
      echo "Bind address: ${_GLOBAL_BIND}"
      echo "Install user: ${_GLOBAL_USER}"
      echo "Install dir: ${_GLOBAL_DIR}"
   fi   
}

parse_options $*
check_pre_req
install_switchyard
register_service
start_service_and_wait
