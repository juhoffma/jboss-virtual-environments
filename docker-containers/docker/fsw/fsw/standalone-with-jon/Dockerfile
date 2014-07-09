#
#
#
# Base image has jdk7 and jboss user

FROM jmorales_fsw/standalone:6.0
MAINTAINER jmorales <jmorales@redhat.com>

RUN wget http://RHQSERVER_USER:RHQSERVER_PASSWD@$RHQSERVER_HOST:RHQSERVER_PORT/agentupdate/download -O /tmp/rhq-enterprise-agent.jar
RUN java -jar /tmp/rhq-enterprise-agent.jar --install=/opt/
ADD ./agent-configuration.xml /tmp/agent-configuration.xml
RUN /opt/rhq-agent/bin/rhq-agent.sh -n --config /tmp/agent-configuration.xml

# Expose the required port
EXPOSE 7080

# Start FSW
CMD ["/home/jboss/jboss-eap-6.1/bin/standalone.sh", "-c", "standalone.xml", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]
