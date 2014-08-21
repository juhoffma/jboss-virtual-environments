#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

EAP_HOME=/home/jboss/jboss-eap-6.3
###
# Customize configuration for DTGov
#
PROFILE="standalone.xml"
JBOSS_CONSOLE_LOG=jboss-setup-console.log
STARTUP_WAIT=30
echo "Starting JBoss EAP in 'admin-only' mode."
# To start in admin-mode user:   --admin-only
# Workflows can not be installed in admin-only as they are installed using s-ramp console
${EAP_HOME}/bin/standalone.sh -c ${PROFILE} -b 0.0.0.0 -bmanagement 0.0.0.0 2>&1 > $JBOSS_CONSOLE_LOG &

# Some wait code. Wait till the system is ready. Basically copied from the EAP .sh scripts.
count=0
launched=false

until [ $count -gt $STARTUP_WAIT ]
  do
    grep 'JBAS015874:' $JBOSS_CONSOLE_LOG > /dev/null
    if [ $? -eq 0 ] ; then
      launched=true
      break
    fi
    sleep 1
    let count=$count+1;
  done

  #Check that the platform has started, otherwise exit.

 if [ $launched = "false" ]
 then
        echo "JBoss EAP did not start correctly. Exiting."
        exit 1
else
        echo "JBoss EAP started."
fi

/home/jboss/apache-ant-1.9.4/bin/ant -f /tmp/dtgov-1.3.0.Final/build.xml seed -Ds-ramp.shell.password=admin123!

# And we can shutdown the system using the CLI.
echo "Shutting down JBoss EAP."
${EAP_HOME}/bin/jboss-cli.sh -c ":shutdown"

