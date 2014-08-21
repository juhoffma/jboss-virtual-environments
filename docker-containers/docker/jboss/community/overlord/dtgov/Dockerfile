# Steps taken to create this image
# docker build --rm -t jboss.org/dtgov:1.3.0  .
# docker run -p 9990:9990 -p 9999:9999 -p 8080:8080 -it jboss.org/dtgov:1.3.0
#
#
FROM jboss/jboss_eap:6.3.0

# USER root
# RUN yum -y install ant; yum clean all
# USER jboss
USER root
RUN yum -y install wget tar; yum clean all
USER jboss
RUN wget http://mirrors.ukfast.co.uk/sites/ftp.apache.org/ant/binaries/apache-ant-1.9.4-bin.tar.gz; tar -xvzf apache-ant-1.9.4-bin.tar.gz

ADD files/dtgov-1.3.0.Final.zip /home/jboss/
ADD files/s-ramp-0.5.0.Final.zip /home/jboss/
ADD files/install-workflows.sh /home/jboss/

RUN unzip /home/jboss/s-ramp-0.5.0.Final.zip -d /tmp
RUN unzip /home/jboss/dtgov-1.3.0.Final.zip -d /tmp

RUN /home/jboss/apache-ant-1.9.4/bin/ant -f /tmp/s-ramp-0.5.0.Final/build.xml -Ds-ramp-distro.choices.platform=1 -Ds-ramp-distro.choices.platform.jboss-eap-6.path=/home/jboss/jboss-eap-6.3 -Doverlord-commons.admin.password=admin123!
RUN /home/jboss/apache-ant-1.9.4/bin/ant -f /tmp/dtgov-1.3.0.Final/build.xml -Ddtgov-distro.choices.platform=1 -Ddtgov-distro.choices.platform.jboss-eap-6.path=/home/jboss/jboss-eap-6.3

RUN /home/jboss/install-workflows.sh

ENTRYPOINT ["/home/jboss/jboss-eap-6.3/bin/standalone.sh"]
CMD ["-b","0.0.0.0", "-bmanagement","0.0.0.0"]
