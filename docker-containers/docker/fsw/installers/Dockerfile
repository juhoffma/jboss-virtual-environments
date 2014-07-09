#
# http://goldmann.pl/blog/2013/11/20/developing-with-wildfly-jboss-developer-studio-and-docker/
# docker pull goldmann/jbds-wildfly
# docker run -i -t goldmann/jbds-wildfly:wildfly
#

FROM centos
MAINTAINER jmorales <jmorales@redhat.com>

# Update box
RUN yum -y update;yum clean all

# Set the root password
RUN echo "root:password" | chpasswd

ADD software /software

# Start SSHD
CMD ["/bin/bash", "-l"]
