#
#
#
FROM jboss_fsw/sy
MAINTAINER jmorales <jmorales@redhat.com>

# Expose the required port
EXPOSE 8080 9990 9999 8787

USER jboss
#
# We add latest hawtio console: hawtio-default-1.4.14.war
#
ADD files/hawtio.war /home/jboss/jboss-eap-6.1/standalone/deployments/

# Start Container
#ENTRYPOINT ["/home/jboss/jboss-eap-6.1/bin/standalone.sh"]
#CMD ["-c", "standalone.xml", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]
CMD ["/home/jboss/jboss-eap-6.1/bin/standalone.sh", "-c", "standalone.xml", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]

