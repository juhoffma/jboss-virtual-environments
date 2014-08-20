# Steps taken to create this image
# docker build --rm -t jboss/jboss_eap:6.3.0  .
# docker run -p 9990:9990 -p 9999:9999 -p 8080:8080 -it jboss/jboss_eap:6.3.0
# 
# Delete all containers: docker ps -a | cut -f 1 -d " " | grep -v CONTA | xargs docker rm
#
#
# Get required ZIP file from: https://access.redhat.com/jbossnetwork/restricted/softwareDownload.html?softwareId=32483&product=appplatform
#
#
FROM jboss/base
WORKDIR /home/jboss
ADD files/jboss-eap-6.3.0.zip /home/jboss/
RUN unzip /home/jboss/jboss-eap-6.3.0.zip
RUN /home/jboss/jboss-eap-6.3/bin/add-user.sh admin admin123! --silent
EXPOSE 9990
EXPOSE 9999
EXPOSE 8080

ENTRYPOINT ["/home/jboss/jboss-eap-6.3/bin/standalone.sh"]
CMD ["-b","0.0.0.0", "-bmanagement","0.0.0.0"]
