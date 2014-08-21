#
#
#
FROM jboss_fsw/sy
MAINTAINER jmorales <jmorales@redhat.com>

# Expose the required port
EXPOSE 8080 9990 9999 8787

# Install the files that will copy the artifact from the volume to the deployment target 
#
#
ADD files/customer.h2.db /home/jboss/jboss-eap-6.1/standalone/data/h2/
ADD files/lab1-1.0.0.jar /home/jboss/jboss-eap-6.1/standalone/deployments/
ADD files/install.commands /home/jboss/
ADD files/install.sh /home/jboss/

RUN /home/jboss/jboss-eap-6.1/bin/add-user.sh -a -u guest -p guestp.1 -r ApplicationRealm -ro guest --silent
#RUN /home/jboss/install.sh

# Start Container
CMD ["/home/jboss/jboss-eap-6.1/bin/standalone.sh", "-c", "standalone-full.xml", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]
