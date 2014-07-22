#
#

FROM centos
MAINTAINER jmorales <jmorales@redhat.com>

# Update the system
RUN yum -y update;yum clean all

# Install java and sshd
RUN yum -y install java-1.7.0-openjdk-devel unzip; yum clean all
ENV JAVA_HOME /usr/lib/jvm/java
ENV HOME /home/jboss

RUN groupadd -r jboss -g 433 && useradd -u 431 -r -g jboss -d /home/jboss -s /sbin/nologin -c "Docker image user" jboss && mkdir /home/jboss && chown -R jboss:jboss /home/jboss && echo "jboss:jboss" | chpasswd && echo "root:root" | chpasswd
#RUN groupadd -r jboss -g 433 && useradd -u 431 -r -g jboss jboss && mkdir /home/jboss && chown -R jboss:jboss /home/jboss && echo "jboss:jboss" | chpasswd && echo "root:root" | chpasswd

USER jboss
WORKDIR /home/jboss

CMD ["/bin/bash","-l"]
