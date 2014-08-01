#
#
# http://nilhcem.github.io/FakeSMTP/
#
# Base image has jdk7 and jboss user

FROM jmorales_fsw/base:6.0
MAINTAINER jmorales <jmorales@redhat.com>

USER root
WORKDIR /opt
ADD fakeSMTP-1.10.jar /opt/

# Expose the required port
EXPOSE 25

# Start FSW
CMD ["java","-jar","fakeSMTP-1.10.jar", "-s","-b"]
