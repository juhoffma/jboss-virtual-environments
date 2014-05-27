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
	echo "       $0 [-H hostname] [-u user] [-s sudouser] [-h hostname:ip] [-j jdk-tar-filename] [-l limits] [-d install_dir] [-?]"
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
      echo 'export JAVA_HOME=/opt/data/java' > /etc/profile.d/java.sh
      echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile.d/java.sh
      echo_info "Java profile created at /etc/profile.d/java.sh"
      # Source the file to have java
      . /etc/profile.d/java.sh
   fi   
}

function setup_ulimits {
# setup limits.conf
# Linux distributions have a maximum number of files that a process can have open at one time. If this maximum number of files is set too low, JBoss Developer Studio will not start. 
# You must open the /etc/security/limits.conf file and ensure that the soft nofile and hard nofile variables have values of 9216 at a minimum.
# If the variables have smaller values, the values must be increased to 9216. If the variables are not specified, the following lines must be added to the file:
# * soft nofile 9216
# * hard nofile 9216
echo "NO OP"
}

#
# Parses command line arguments for script and check required params
#
function parse_options() {
   while getopts "u:s:h:H:j:d:?" opt "$@"; do
     case $opt in
       u)
         add_user $OPTARG
         ;;
       s)
         add_sudo_user $OPTARG
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
