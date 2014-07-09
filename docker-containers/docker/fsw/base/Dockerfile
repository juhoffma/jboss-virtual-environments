#
#

FROM centos
MAINTAINER jmorales <jmorales@redhat.com>

# Update the system
RUN yum -y update;yum clean all

# Install java and sshd
RUN yum -y install java-1.7.0-openjdk-devel unzip; yum clean all
ENV JAVA_HOME /usr/lib/jvm/jre

RUN groupadd -r jboss -g 433 && useradd -u 431 -r -g jboss -d /home/jboss -s /sbin/nologin -c "Docker image user" jboss && mkdir /home/jboss && chown -R jboss:jboss /home/jboss
#RUN groupadd -r jboss -g 433 && useradd -u 431 -r -g jboss jboss

USER jboss

CMD ["/bin/bash","-l"]
