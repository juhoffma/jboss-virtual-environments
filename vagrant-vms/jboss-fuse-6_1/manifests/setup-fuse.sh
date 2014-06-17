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
# Import jboss functions
if [ ! -f ${DIR}/jboss_functions ]
then
   echo "${DIR}/jboss_functions does not exist. This script can not run"
   exit 255
else
   . ${DIR}/jboss_functions
fi
function sedeasy {
  echo "sed -i \"s/$(echo $1 | sed -e 's/\([[\/.*]\|\]\)/\\&/g')/$(echo $2 | sed -e 's/[\/&]/\\&/g')/g\" $3"
}

: ${BINARY:="jboss-fuse-full-6.1.0.redhat-379.zip"}
: ${PRODUCT_NAME:="Fuse"}
: ${PRODUCT_SCRIPTNAME:="sy"}
: ${FILES_DIR:=${DIR}"/files"}
: ${INSTALLER:="${FILES_DIR}/${BINARY}"}

: ${DEFAULT_USER:="jboss"}
: ${DEFAULT_GROUP:="jboss"}
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


#
# Checking pre requisites for installing product
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

# Installs binaries
# 
# Arguments:
#   $1: path
#   $2: user
function install_fuse {
   local _instance_name=$_GLOBAL_INSTANCE
   local _install_path=$_GLOBAL_DIR
   local _user=$_GLOBAL_USER
   local _group=$_GLOBAL_GROUP
   local _admin_user=$_GLOBAL_ADMIN_USER
   local _admin_pwd=$_GLOBAL_ADMIN_PWD 

   # Validate that the target installation does not already exist
   if [ -d ${_install_path}/jboss-fuse-6.1.0.redhat-379 ] || [ -d ${_install_path}/${_instance_name} ]
   then
      echo_nook "Target directory already exists. Please remove it before installing again."
      exit 250
   else
      echo_info "${PRODUCT_NAME} will be installed in ${_install_path}"  
   fi

   echo_info "Install ${PRODUCT_NAME}" 
   unzip ${INSTALLER} -d ${_install_path}

   if [ ! -e  ${_install_path}/jboss-fuse-6.1.0.redhat-379 ]
   then
      echo_nook "Installation went wrong!!!"
      exit 253
   else
      echo "$PRODUCT_NAME installed successsfuly"
   fi

   echo_info "Renaming the instance dir to ${_instance_name} to honour name of ${PRODUCT_NAME} install"
   mv ${_install_path}/jboss-fuse-6.1.0.redhat-379 ${_install_path}/${_instance_name}
   
   # We need to  create admin user and password
   echo " " >>  ${_install_path}/${_instance_name}/etc/users.properties
   echo "${_admin_user}=${_admin_pwd},admin" >>  ${_install_path}/${_instance_name}/etc/users.properties
  
   # After everything is done, fix owner
   echo_info "Setting permissions to ${_install_path}/${_instance_name} for user ${_user}"
   chown -R $_user:$_group ${_install_path}/${_instance_name}
   
   # As a return it will output the install path
   echo "${_install_path}/${_instance_name}"
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
         #_GLOBAL_BIND_ALL=$OPTARG
         ;;
       b)
         #_GLOBAL_BIND_PUBLIC=$OPTARG
         ;;
       m)
         #_GLOBAL_BIND_MANAGEMENT=$OPTARG
         ;;
       U)
         local _user=$OPTARG
         IFS=':' read -ra _arr <<< "$_user"   
         _GLOBAL_USER=${_arr[0]}
         if [ -z  "${_arr[1]}" ]
         then
            _GLOBAL_GROUP=$_GLOBAL_USER
         else
            _GLOBAL_GROUP=${_arr[1]}
         fi            
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
         #_GLOBAL_PROFILE=$OPTARG
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
      if [[ "$_GLOBAL_GROUP" == "" ]] 
      then 
         _GLOBAL_GROUP=$_DEFAULT_GROUP
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
      #echo "Bind address: ${_GLOBAL_BIND}"
      #echo "Bind address management: ${_GLOBAL_BIND_MANAGEMENT}"
      #echo "Bind address public: ${_GLOBAL_BIND_PUBLIC}"
      echo "Install user: ${_GLOBAL_USER}"
      echo "Install group: ${_GLOBAL_GROUP}"
      echo "Admin user: ${_GLOBAL_ADMIN_USER}"
      echo "Admin password: ${_GLOBAL_ADMIN_PWD}"
      echo "Install dir: ${_GLOBAL_DIR}"
   fi   
}


# If this script is not run with sudo or su fail
fail_if_not_root

parse_options $*
check_pre_req
install_fuse
#register_service
#start_service_and_wait $_GLOBAL_INSTANCE $_GLOBAL_DIR
