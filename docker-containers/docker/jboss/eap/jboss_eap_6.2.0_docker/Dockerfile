# VERSION 0.0.1
#
# Steps taken to create this image
# docker build -rm -t jorgemoralespou/eap62 .
# docker run -p ["127.0.0.1:9990:9990","127.0.0.1:2222:22"] -t -i jorgemoralespou/eap62
# If needed, execute it with full provileges --> docker run -privileged -t -i jorgemoralespou/eap62
# 
# Delete all containers: docker ps -a | cut -f 1 -d " " | grep -v CONTA | xargs docker rm
#
#
# Get required ZIP file from: https://access.redhat.com/jbossnetwork/restricted/softwareDownload.html?softwareId=26463&product=appplatform
#
#
FROM centos
MAINTAINER Jorge Morales "jorgemoralespou@gmail.com"
# Only do yum update if there is internet connectivity and there is a need to install software from repos, like unzip and java
#RUN yum -y update
RUN yum install -y unzip
RUN yum install -y java-1.7.0-openjdk
RUN yum install -y openssh-server
#RUN mkdir /var/run/sshd
RUN service sshd start
RUN service sshd restart
RUN echo "root:password" | chpasswd
ADD jboss-eap-6.2.0.zip /tmp/
WORKDIR /opt
RUN unzip /tmp/jboss-eap-6.2.0.zip
RUN /opt/jboss-eap-6.2/bin/add-user.sh admin admin123! --silent
EXPOSE 22
EXPOSE 9990
EXPOSE 9999

#CMD ["/opt/jboss-eap-6.2/bin/standalone.sh"]
#ENTRYPOINT ["/opt/jboss-eap-6.2/bin/standalone.sh","-b","0.0.0.0"]
CMD ["/bin/bash", "-l"]

