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

##
# Installs additional packages
#
#
function install_additional_packages {
   echo "Installing additional packages (java, unzip,...)"
   # TODO: Check for package being installed, otherwise execute yum and check for results. 
   yum -y install java-1.7.0-openjdk unzip
}

function usage {
   # TODO: Explain how it works
	echo "Usage: "
	echo "       $0 [-H hostname] [-U user] [-s sudouser] [-h hostname:ip] [-j jdk-tar-filename] [-l limits] [-d install_dir] [-?]"
	echo ""
	echo ""
	exit 250
}

# Installs Oracle JDK (as root)
#
# Arguments:
#  $1: tar.gz filename
#
function install_Oracle_JDK7 {
   local _filename=$1
   local RET=0
   
   local _completefile=$DIR/files/$_filename
   if [ -z  $_GLOBAL_DIR ]
   then
      echo_nook "To install java you must also specify -d option for the install path"
      exit 255
   fi
   if [ ! -d $_GLOBAL_DIR ]
   then
      mkdir -p $_GLOBAL_DIR 2> /dev/null
      [ $? -ne 0 ] && exit_error "Impossible to create $_GLOBAL_DIR"
   fi 
   if [ ! -f $_completefile ]
   then
      echo_nook "Java installer binary not found in: $_completefile"
      exit 255
   else   
      echo_info "Installing java: $_filename"
      _linkname=$(tar -tvf $_completefile | head -1 | awk '{print $6'})
      tar -xvzf $_completefile -C $_GLOBAL_DIR 2>/dev/null
      [ $? -ne 0 ] && exit_error "Java installation error"
      
      echo_ok "Java installed succesfully"
      ln -s $_GLOBAL_DIR/$_linkname $_GLOBAL_DIR/java 2> /dev/null
      #[ $? -ne 0 ] && exit_error "Java installation error"

      echo_info "Link for $_GLOBAL_DIR/$_linkname created at $_GLOBAL_DIR/java"  
      echo "export JAVA_HOME=${_GLOBAL_DIR}/java" > /etc/profile.d/java.sh
      echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile.d/java.sh
      echo_info "Java profile created at /etc/profile.d/java.sh"
      # TODO: fix /etc/java/java.conf
      ## java ##
      /usr/sbin/alternatives --install /usr/bin/java java $_GLOBAL_DIR/java/jre/bin/java 200000
      /usr/sbin/alternatives --install /usr/bin/javaws javaws $_GLOBAL_DIR/java/jre/bin/javaws 200000
      #/usr/sbin/alternatives --install /usr/lib64/mozilla/plugins/libjavaplugin.so libjavaplugin.so.x86_64 $_GLOBAL_DIR/java/jre/lib/amd64/libnpjp2.so 200000
      /usr/sbin/alternatives --install /usr/bin/javac javac $_GLOBAL_DIR/java/bin/javac 200000
      /usr/sbin/alternatives --install /usr/bin/jar jar $_GLOBAL_DIR/java/bin/jar 200000
      # Source the file to have java
      . /etc/profile.d/java.sh
   fi   
}

#
# 
# Arguments:
#   $1: domain (*,jboss,username,group)
#   $2: type (soft,hard)
#   $3: item (proc,nofile,...)
#   $4: new_value
function setup_ulimit_for {
   local _domain=$1
   local _type=$2
   local _item=$3
   local _value=$4
   
   _find_cmd=$(cat /etc/security/limits.conf | grep "$_domain" | grep "$_type" | grep "$_item")
   
   if [[ "" == $_find_cmd ]]  
   then
      echo "$_domain                    $_type       $_item           $_value" >> /etc/security/limits.conf
      echo "Adding"
   else
      local _patterned_domain=`echo "$_domain" | sed 's:[]\[\^\$\.\*\/]:\\\\&:g'`
      sed -i -r "s/^(.*)($_patterned_domain[ ]+$_type[ ]+$_item[ ]+)([0-9]*)$/\2$_value/g" /etc/security/limits.conf
      echo "Modifying"
   fi   
   echo "ulimit set for $_domain $_type $_item with value $_value"
}

#
#
# Arguments:
#   $1: limit value
function setup_ulimits {
   local _limit=$1
   
   echo "Setting ulimits to $_limit"

   setup_ulimit_for "*" "soft" "nproc" "$_limit"
   setup_ulimit_for "*" "hard" "nproc" "$_limit"
   setup_ulimit_for "*" "soft" "nofile" "$_limit"
   setup_ulimit_for "*" "hard" "nofile" "$_limit"
}

#
# Parses command line arguments for script and check required params
#
function parse_options() {
   while getopts "U:s:h:H:j:d:l:?" opt "$@"; do
     case $opt in
       U)
         local _user=$OPTARG
         IFS=':' read -ra _arr <<< "$_user"
         add_user ${_arr[0]} ${_arr[1]}  
         ;;
       g)
         add_group $OPTARG
         ;;
       s)
         local _user=$OPTARG
         IFS=':' read -ra _arr <<< "$_user"
         add_sudo_user ${_arr[0]} ${_arr[1]}         
         ;;
       H)
         set_hostname  $OPTARG
         ;;
       j)
         _ORACLE_JDK7=$OPTARG
         ;;
       l)
         setup_ulimits  $OPTARG
         ;;
       d)
         _GLOBAL_DIR=$OPTARG
         ;;
       h)
         local _host=$OPTARG
         IFS=':' read -ra _arr <<< "$_host"
         add_hostname ${_arr[0]} ${_arr[1]}        
         ;;
       ?) 
         usage
         ;;  
       \?)
         echo "Invalid option: -$OPTARG" >&2
         ;;
      esac
   done
}

# If this script is not run with sudo or su fail
fail_if_not_root

parse_options $*

if [ ! -z $_ORACLE_JDK7 ]
then
   install_Oracle_JDK7 $_ORACLE_JDK7
fi
# Install additional packages
#install_additional_packages

# TODO:
# setup domain
# setup ...
