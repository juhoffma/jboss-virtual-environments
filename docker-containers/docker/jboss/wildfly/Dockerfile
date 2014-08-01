#
# http://goldmann.pl/blog/2013/11/20/developing-with-wildfly-jboss-developer-studio-and-docker/
# docker pull goldmann/jbds-wildfly
# docker run -i -t goldmann/jbds-wildfly:wildfly
#
FROM goldmann/f20
MAINTAINER Jorge 

# Install java and sshd
RUN yum -y install java-1.7.0-openjdk-devel openssh-server wildfly

# Set the root password
RUN echo "root:password" | chpasswd

# Make sure we don't do DNS lookups
RUN echo "UseDNS no" >> /etc/ssh/sshd_config

# Add management user for remote management
RUN /usr/share/wildfly/bin/add-user.sh admin admin123! --silent

# Expose the required port
EXPOSE 10022:22 18080:8080 19990:9990

# Start SSHD
ENTRYPOINT sshd-keygen > /dev/null && echo "The container is running. You can use your IDE now to deploy your apps." && /usr/sbin/sshd -D &> /dev/null
