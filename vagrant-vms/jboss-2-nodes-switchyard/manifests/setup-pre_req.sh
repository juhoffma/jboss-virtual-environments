#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "$DIR"
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
   echo "== Installing additional packages (java, unzip,...)"
   # TODO: Check for package being installed, otherwise execute yum and check for results. 
   yum -y install java-1.7.0-openjdk unzip
}

#
# Parses command line arguments for script and check required params
#
function parse_options() {
   while getopts "u:h:" opt "$@"; do
     case $opt in
       u)
         add_user $OPTARG
         ;;
       h)
         local _host=$OPTARG
         add_hostname ${_host%:*} ${_host##*:}
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

# Install additional packages
install_additional_packages
