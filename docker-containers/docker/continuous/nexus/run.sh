#sh build.sh
docker run -d -e NEXUS_WEBAPP_CONTEXT_PATH=/ -name nexus -p 8081:8081 -v /opt/sonatype-work continuous/nexus
