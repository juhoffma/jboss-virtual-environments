#
# Installation of jenkins: https://github.com/aespinosa/docker-jenkins/blob/master/Dockerfile
# 
FROM jboss/base:1.0.0
MAINTAINER Jorge Morales "jmorales@redhat.com"

USER root
ADD http://mirrors.jenkins-ci.org/war/1.574/jenkins.war /opt/jenkins.war
RUN chmod 644 /opt/jenkins.war
ENV JENKINS_HOME /jenkins
ENTRYPOINT ["java", "-jar", "/opt/jenkins.war"]
EXPOSE 8080

CMD [""]
