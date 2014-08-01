#
#
#
# Base image has jdk7 and jboss user

FROM jmorales_fsw/dtgov:6.0.0
MAINTAINER jmorales <jmorales@redhat.com>

# Expose the required port
EXPOSE 8080 9990 9999 8787

# Start FSW
CMD ["/home/jboss/jboss-eap-6.1/bin/standalone.sh", "-c", "standalone.xml", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]
