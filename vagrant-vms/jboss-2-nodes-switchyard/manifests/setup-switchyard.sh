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
: ${FILES_DIR:=${DIR}"/files"}
: ${INSTALLER:="${FILES_DIR}/${FSWJAR}"}

: ${DEFAULT_USER:="jboss"}
: ${DEFAULT_PROFILE:="standalone-ha.xml"}
: ${DEFAULT_BIND_ALL:="0.0.0.0"}
: ${DEFAULT_BIND_MANAGEMENT:="0.0.0.0"}
: ${DEFAULT_BIND_PUBLIC:="0.0.0.0"}
: ${DEFAULT_DIR:="/opt"}
: ${DEFAULT_ADMIN_PWD:="admin123!"}

usage() {
   # TODO: Explain how it works
	echo "Usage: "
	echo "       $0 -i instance_name [-m bind_address_management] [-b bind_address_public] [-B bind_all_address] [-U OS_user] [-u jboss_admin_user] [-p admin_password] [-i install_dir] [-P profile] [-?]"
	echo ""
	echo ""
	exit 250
}

# Creates encoded password for management realm
#
# Arguments:
#   $1: user
#   $2: password
function encrypt_admin_password { 
   local _user=$_GLOBAL_ADMIN_USER
   local _password=$_GLOBAL_ADMIN_PWD
   
   MI_CLASSPATH="${DIR}/files/encrypt/jboss-client.jar:${DIR}/files/encrypt/jbosssx-3.0.0.Final.jar:${DIR}/files/encrypt/:"

   echo "$(java -cp $MI_CLASSPATH EncryptPassword $_user $_password)"
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
   # Source java profile to get JAVA_HOME
   [ -r /etc/profile.d/java.sh ] && . /etc/profile.d/java.sh
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
   local _admin_user=$_GLOBAL_ADMIN_USER
   local _admin_pwd=$_GLOBAL_ADMIN_PWD 

   # Validate that the target installation does not already exist
   if [ -d ${_install_path}/jboss-eap-6.1 ] || [ -d ${_install_path}/${_instance_name} ]
   then
      echo_nook "Target directory already exists. Please remove it before installing again."
      exit 250
   else
      echo_info "${PRODUCT_NAME} will be installed in ${_install_path}"  
   fi

   local _encrypted_admin=$(encrypt_admin_password)
   
   # TODO: Do all the sed into tmp files, not the real ones.
   
   echo "Password for admin encrypted ($_encrypted_admin)"
   # Before we install, we need to modify the install.xml to have the correct install path
   sed -i -e "s/<installpath>.*<\/installpath>/<installpath>$(echo ${_install_path} | sed -e 's/[\/&]/\\&/g')<\/installpath>/g" ${FILES_DIR}/install-${PRODUCT_SCRIPTNAME}.xml
   # If admin password is set, change it
   sed -i -e "s/adminPassword\" value=\".*\"/adminPassword\" value=\"$(echo ${_encrypted_admin} | sed -e 's/[\/&]/\\&/g')\"/g" ${FILES_DIR}/install-${PRODUCT_SCRIPTNAME}.xml
   sed -i -e "s/password=.*/password=$(echo ${_admin_pwd} | sed -e 's/[\/&]/\\&/g')/g" ${FILES_DIR}/install-${PRODUCT_SCRIPTNAME}.xml.variables
   sed -i -e "s/storepass=.*/storepass=$(echo ${_admin_pwd} | sed -e 's/[\/&]/\\&/g')/g" ${FILES_DIR}/install-${PRODUCT_SCRIPTNAME}.xml.variables
   sed -i -e "s/keystorepwd=.*/keystorepwd=$(echo ${_admin_pwd} | sed -e 's/[\/&]/\\&/g')/g" ${FILES_DIR}/install-${PRODUCT_SCRIPTNAME}.xml.variables

   echo_info "Install ${PRODUCT_NAME}" 
   java -jar ${INSTALLER} ${FILES_DIR}/install-${PRODUCT_SCRIPTNAME}.xml -variablefile ${FILES_DIR}/install-${PRODUCT_SCRIPTNAME}.xml.variables

   if [ ! -e  ${_install_path}/jboss-eap-6.1 ]
   then
      echo_nook "Installation went wrong!!!"
      exit 253
   else
      echo "$PRODUCT_NAME installed successsfuly"
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
  
   # Removing data dir to rename without issues
   rm -rf ${_install_path}/${_instance_name}/standalone/data
   rm -rf ${_install_path}/${_instance_name}/standalone/tmp
   # Sed a change for logging configuration
   sed -i -e "s/jboss-eap-6.1/${_instance_name}/g" ${_install_path}/${_instance_name}/standalone/configuration/logging.properties
   
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
   local _bind_addr=$_GLOBAL_BIND_ALL
   local _bind_addr_management=$_GLOBAL_BIND_MANAGEMENT
   local _bind_addr_public=$_GLOBAL_BIND_PUBLIC
  

   echo_info "Set bind address for $_config configuration in $_install_dir/$_instance_name"

   # TODO: Replace every token, for every config alternative
   # See: https://docs.jboss.org/author/display/AS71/Command+line+parameters
   `cat  $_install_dir/$_instance_name/bin/${_config}.conf | grep "jboss.bind.address=" | grep -v "#"`
   RET=$?   
   if [ $RET != 0 ]
   then
#      echo "JAVA_OPTS=\"\$JAVA_OPTS -Djboss.bind.address=${_bind_addr} -Djboss.bind.address.management=${_bind_addr} -Djboss.bind.address.unsecure=${_bind_addr} \"" >> ${_install_dir}/${_instance_name}/bin/${_config}.conf
      echo "JAVA_OPTS=\"\$JAVA_OPTS -Djboss.bind.address=${_bind_addr_public} -Djboss.bind.address.management=${_bind_addr_management} \"" >> ${_install_dir}/${_instance_name}/bin/${_config}.conf
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
   local _profile=$_GLOBAL_PROFILE

   if [ ! -e /etc/init.d/${_instance_name} ]
   then
       cp ${FILES_DIR}/jboss-instance.sh /etc/init.d/${_instance_name}
       chmod 755 /etc/init.d/${_instance_name}
       mkdir -p /etc/jboss-as
       cp ${FILES_DIR}/jboss-instance.conf /etc/jboss-as/${_instance_name}.conf
       if [ -e /sbin/chkconfig ]
       then
         /sbin/chkconfig --add ${_instance_name} 
         /sbin/chkconfig --level 345 ${_instance_name} on
       else  
         # TODO: If there is no chkconfig, register the service the old way
         echo "Creating links"
         
       fi
   fi
   
   # Sed configuration
   sed -i -e "s/JBOSS_HOME=.*/JBOSS_HOME=$(echo ${_install_dir}/${_instance_name} | sed -e 's/[\/&]/\\&/g')/g" /etc/jboss-as/${_instance_name}.conf
   sed -i -e "s/JBOSS_USER=.*/JBOSS_USER=$(echo ${_user} | sed -e 's/[\/&]/\\&/g')/g" /etc/jboss-as/${_instance_name}.conf
   sed -i -e "s/JBOSS_CONFIG=.*/JBOSS_CONFIG=$(echo ${_profile} | sed -e 's/[\/&]/\\&/g')/g" /etc/jboss-as/${_instance_name}.conf
}


#
# Start the server
function start_service_and_wait {
   local _install_dir=$_GLOBAL_DIR
   local _instance_name=$_GLOBAL_INSTANCE

   if [ -e /usr/sbin/service ]
   then
      service ${_instance_name} start
   else
      /etc/init.d/${_instance_name} start
   fi
   
   #
   # Wait until the server is started
   #
   sleep 5
#   timeout 120 grep -q 'JBAS015874:' <(tail -f ${_install_dir}/${_instance_name}/standalone/log/server.log)
   wait_for_startup 120 ${_install_dir}/${_instance_name}/standalone/log/server.log
}


#
# Arguments:
#   $1: timeout
#   $2: jboss_console_log
function wait_for_startup {
  local _timeout=$1
  local _log_file=$2
  local count=0

  until [ $count -gt $_timeout ]
  do
    grep 'JBAS015874:' $_log_file > /dev/null 
    if [ $? -eq 0 ] ; then
      break
    fi 
    sleep 1
    let count=$count+1;
  done

}

#
# Parses command line arguments for script and check required params
#
function parse_options() {
   local _configured=0
   
   while getopts "i:b:u:U:d:p:m:B:P:" opt "$@"; do
     case $opt in
       i)
         _GLOBAL_INSTANCE=$OPTARG
         _configured=1
         ;;
       B)
         _GLOBAL_BIND_ALL=$OPTARG
         ;;
       b)
         _GLOBAL_BIND_PUBLIC=$OPTARG
         ;;
       m)
         _GLOBAL_BIND_MANAGEMENT=$OPTARG
         ;;
       U)
         _GLOBAL_USER=$OPTARG
         ;;
       u)
         _GLOBAL_ADMIN_USER=$OPTARG
         ;;
       d)
         _GLOBAL_DIR=$OPTARG
         ;;
       p)
         _GLOBAL_ADMIN_PWD=$OPTARG
         ;;
       P)
         _GLOBAL_PROFILE=$OPTARG
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
      if [[ "$_GLOBAL_BIND_ALL" == "" ]]
      then
         _GLOBAL_BIND_ALL=$_DEFAULT_BIND_ALL
      fi
      if [[ "$_GLOBAL_BIND_MANAGEMENT" == "" ]]
      then
         _GLOBAL_BIND_MANAGEMENT=$_DEFAULT_BIND_MANAGEMENT
      fi
      if [[ "$_GLOBAL_BIND_PUBLIC" == "" ]]
      then
         _GLOBAL_BIND_PUBLIC=$_DEFAULT_BIND_PUBLIC
      fi
      if [[ "$_GLOBAL_DIR" == "" ]]
      then   
         _GLOBAL_DIR=$_DEFAULT_DIR
      fi
      if [[ "$_GLOBAL_ADMIN_USER" == "" ]]
      then   
         _GLOBAL_ADMIN_USER=$DEFAULT_ADMIN_USER
      fi      
      if [[ "$_GLOBAL_ADMIN_PWD" == "" ]]
      then   
         _GLOBAL_ADMIN_PWD=$DEFAULT_ADMIN_PWD
      fi      
      if [[ "$_GLOBAL_PROFILE" == "" ]]
      then   
         _GLOBAL_PROFILE=$DEFAULT_PROFILE
      fi          
      echo "Configuration ready"   
      echo "Environment: ${_GLOBAL_INSTANCE}"
      echo "Environment: ${_GLOBAL_PROFILE}"
      echo "Bind address: ${_GLOBAL_BIND}"
      echo "Bind address management: ${_GLOBAL_BIND_MANAGEMENT}"
      echo "Bind address public: ${_GLOBAL_BIND_PUBLIC}"
      echo "Install user: ${_GLOBAL_USER}"
      echo "Admin user: ${_GLOBAL_ADMIN_USER}"
      echo "Admin password: ${_GLOBAL_ADMIN_PWD}"
      echo "Install dir: ${_GLOBAL_DIR}"
   fi   
}


# If this script is not run with sudo or su fail
fail_if_not_root

parse_options $*
check_pre_req
install_switchyard
register_service
start_service_and_wait
