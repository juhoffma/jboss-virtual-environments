#
# Sourced from here: https://github.com/griff/sonatype-nexus-docker
#
FROM jboss/base:1.0.0
MAINTAINER Jorge Morales "jmorales@redhat.com"

USER root
RUN mkdir -p /opt/sonatype-nexus /opt/sonatype-work-template /opt/sonatype-work
RUN wget -O /tmp/nexus-latest-bundle.tar.gz http://www.sonatype.org/downloads/nexus-2.8.1-bundle.tar.gz
RUN tar xzvf /tmp/nexus-latest-bundle.tar.gz -C /opt/sonatype-nexus --strip-components=1
RUN useradd --user-group --system --home-dir /opt/sonatype-nexus nexus
RUN chown -R nexus:nexus /opt/sonatype-work-template /opt/sonatype-work /opt/sonatype-nexus
ENV NEXUS_WEBAPP_CONTEXT_PATH /nexus
ADD files/start_as_nexus.sh /opt/start_as_nexus.sh
ADD files/start_nexus.sh /opt/start_nexus.sh
RUN ln -s /opt/start_nexus.sh /opt/start.sh

CMD ["/opt/start_as_nexus.sh"]
VOLUME /opt/sonatype-work
EXPOSE 8081
