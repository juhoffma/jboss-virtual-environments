#
# http://goldmann.pl/blog/2013/11/20/developing-with-wildfly-jboss-developer-studio-and-docker/
# docker pull goldmann/jbds-wildfly
# docker run -i -t goldmann/jbds-wildfly:wildfly
#

FROM goldmann/f20
MAINTAINER Jorge 

# Install java and sshd
RUN yum -y install java-1.7.0-openjdk-devel openssh-server unzip

# Set the root password
RUN echo "root:password" | chpasswd

# Make sure we don't do DNS lookups
RUN echo "UseDNS no" >> /etc/ssh/sshd_config

ADD jboss-fsw-installer-6.0.0.GA-redhat-4.jar /tmp/
WORKDIR /opt

# Add management user for remote management
#RUN /usr/share/wildfly/bin/add-user.sh admin Admin#70365 --silent

# Expose the required port
EXPOSE 22 8080 9990

# Start SSHD
ENTRYPOINT sshd-keygen > /dev/null && echo "The container is running. You can use your IDE now to deploy your apps." && /usr/sbin/sshd -D &> /dev/null && /bin/bash -l
#CMD ["/bin/bash", "-l"]
