#!/usr/bin/env bash
# http://www.dmartin.es/2014/07/jboss-eap-6-como-servicio-en-rhel-7
# https://coreos.com/docs/running-coreos/platforms/vagrant/
#

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Import common functions
if [ ! -f ${DIR}/common_functions ]
then
   echo "${DIR}/common_functions does not exist. This script can not run"
   exit 255
else
   . ${DIR}/common_functions
fi

# Install Java
#
# http://www.redguava.com.au/2014/03/jenkins-slaves-running-coreos-and-docker/
#
# Installs Oracle JDK (as root)
#
# Arguments:
#  $1: tar.gz filename
#
function install_Oracle_JDK7 {
   local _filename=$1
   local RET=0
   
   local _completefile=$DIR/$_filename
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
      echo "export JAVA_HOME=$_GLOBAL_DIR/java" > /etc/profile.d/java.sh
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

_GLOBAL_DIR=/opt

install_Oracle_JDK7 jdk-7u55-linux-x64.tar.gz


# Install Wildfly 8.2.0
yum install -y unzip

unzip -oXK ${DIR}/jboss-eap-6.3.0.zip -d ${_GLOBAL_DIR}
chown -R vagrant:vagrant ${_GLOBAL_DIR}/jboss-eap-6.3

# Prepare for systemd
mkdir /etc/jboss-as/
cat > /etc/jboss-as/jboss-as.conf <<EOF
## Usuario responsable del proceso
JBOSS_USER=vagrant
## Directorio home de JBoss EAP
JBOSS_HOME=/opt/jboss-eap-6.3
EOF

mkdir -p /var/log/jboss
mkdir -p /var/run/jboss
chown -R vagrant:vagrant /var/log/jboss
chown -R vagrant:vagrant /var/run/jboss

# Create Systemd script
#
# https://coreos.com/docs/launching-containers/launching/getting-started-with-systemd/
#
cat > /etc/systemd/system/jboss-as.service <<EOF
[Unit]
Description=Jboss Application Server
After=syslog.target network.target

[Service]
Type=forking
ExecStart=/opt/jboss-eap-6.3/bin/init.d/jboss-as-standalone.sh start
ExecStop=/opt/jboss-eap-6.3/bin/init.d/jboss-as-standalone.sh stop


[Install]
WantedBy=multi-user.target
EOF

# Reload systemctl and start jboss-as
systemctl daemon-reload
systemctl start jboss-as.service
systemctl status jboss-as.service
systemctl enable jboss-as.service