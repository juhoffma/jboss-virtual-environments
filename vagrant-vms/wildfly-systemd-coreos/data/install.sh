#!/bin/bash
#
# http://www.dmartin.es/2014/07/jboss-eap-6-como-servicio-en-rhel-7
# https://coreos.com/docs/running-coreos/platforms/vagrant/
#

# Install Java
#
# http://www.redguava.com.au/2014/03/jenkins-slaves-running-coreos-and-docker/
#
mkdir /home/core/java
cd /home/core/java
wget -q -O java.tar.gz http://javadl.sun.com/webapps/download/AutoDL?BundleId=83376
tar xzvf java.tar.gz
rm java.tar.gz

rm /home/core/.bashrc
echo 'export PATH=$PATH:/home/core/java/jre1.7.0_51/bin/' > /home/core/.bashrc

mkdir /etc/java
cat /etc/java/java.conf <<EOF
## JAVA_HOME
JAVA_HOME=/home/core/java/jre1.7.0_51/
EOF

# Install Wildfly 8.2.0
tar -xvzf /data/wildfly-8.2.0.Final.tar.gz -C /home/core
chown -R core:core /home/core

# Prepare for systemd
cat > /etc/default/wildfly.conf <<EOF
## Usuario responsable del proceso
JBOSS_USER=core
## Directorio home de JBoss EAP
JBOSS_HOME=/home/core/wildfly-8.2.0.Final
EOF

mkdir /var/log/wildfly
mkdir /var/run/wildfly
chown -R core:core /var/log/wildfly
chown -R core:core /var/run/wildfly

# BUG: As CoreOS does not hae /etc/init.d/functions, we copy it
mkdir /etc/init.d
cp /data/functions /etc/init.d/

# Create Systemd script
#
# https://coreos.com/docs/launching-containers/launching/getting-started-with-systemd/
#
cat > /etc/systemd/system/wildfly.service <<EOF
[Unit]
Description=Jboss Application Server
After=syslog.target network.target

[Service]
Type=forking
ExecStart=/home/core/wildfly-8.2.0.Final/bin/init.d/wildfly-init-redhat.sh start
ExecStop=/home/core/wildfly-8.2.0.Final/bin/init.d/wildfly-init-redhat.sh stop


[Install]
WantedBy=multi-user.target
EOF

# Reload systemctl and start wildfly
systemctl daemon-reload
systemctl start wildfly.service
systemctl status wildfly.service
systemctl enable wildfly.service