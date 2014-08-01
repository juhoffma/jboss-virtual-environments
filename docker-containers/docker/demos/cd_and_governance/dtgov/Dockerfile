#
#
#
FROM jboss_fsw/dtgov
MAINTAINER jmorales <jmorales@redhat.com>

# Expose the required port
EXPOSE 8080 9990 9999 8787

ADD files/dtgov.properties /home/jboss/jboss-eap-6.1/standalone/configuration/


# Start Container
CMD ["/home/jboss/jboss-eap-6.1/bin/standalone.sh", "-c", "standalone.xml", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]
